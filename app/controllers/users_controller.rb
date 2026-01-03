class UsersController < ApplicationController
  class InvalidUserRequestError < StandardError; end

  HONEYPOT_FIELD = :url

  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
  end

  def create
    validate_honeypot!

    @user = User.new(user_params)
    if @user.save
      # Start a session for the new user
      start_new_session_for @user
      redirect_to after_authentication_url, notice: I18n.t("views.users.create.success")
    else
      render :new, status: :unprocessable_content
    end
  rescue InvalidUserRequestError
    redirect_to root_path
  end

  def update
    password = params.dig(:user, :password)

    unless current_user.authenticate(password)
      redirect_to account_path, alert: I18n.t("views.account.update.invalid_password")
      return
    end

    if current_user.update(user_update_params)
      redirect_to account_path, notice: I18n.t("views.account.update.success")
    else
      render "account/show", status: :unprocessable_content
    end
  end

  def destroy
    password = params.dig(:user, :password)

    unless current_user.authenticate(password)
      redirect_to account_path, alert: I18n.t("views.users.destroy.invalid_password")
      return
    end

    keep_contributions = params[:keep_contributions] == "1"
    destroy_user_account(keep_contributions:)
    terminate_session
    redirect_to root_path, notice: I18n.t("views.users.destroy.success")
  end

  private
    def destroy_user_account(keep_contributions: false)
      current_user.schedule_for_deletion
      Users::DestroyUserJob.perform_later(current_user.id, keep_contributions)
    end

    def validate_honeypot!
      raise InvalidUserRequestError if honeypot_param.present?
    end

    def honeypot_param
      params.require(:user).delete(HONEYPOT_FIELD)
    end

    def user_params
      params.require(:user).permit(:username, :email_address, :password, :password_confirmation)
    end

    def user_update_params
      params.require(:user).permit(:username, :email_address)
    end
end
