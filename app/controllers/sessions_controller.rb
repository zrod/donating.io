class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  before_action :redirect_if_authenticated, only: %i[ new create ]

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: I18n.t("controllers.sessions.create.too_many_requests") }

  def new; end

  def create
    user = User.authenticate_by(params.permit(:email_address, :password))

    if user.nil? || user.community_user?
      redirect_to new_session_path, alert: I18n.t("controllers.sessions.create.invalid_credentials")
    else
      start_new_session_for user
      redirect_to after_authentication_url
    end
  end

  def destroy
    terminate_session
    redirect_to root_path
  end
end
