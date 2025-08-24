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
      render :new, status: :unprocessable_entity
    end
  rescue InvalidUserRequestError
    redirect_to root_path
  end

  def edit
  end

  def update
  end

  private
    def validate_honeypot!
      raise InvalidUserRequestError if honeypot_param.present?
    end

    def honeypot_param
      params.require(:user).delete(HONEYPOT_FIELD)
    end

    def user_params
      params.require(:user).permit(:username, :email_address, :password, :password_confirmation)
    end
end
