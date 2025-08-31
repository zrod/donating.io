require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should allow unauthenticated access to new action" do
    get new_session_url
    assert_response :success
  end

  test "should allow unauthenticated access to create action with invalid credentials" do
    post session_url, params: { email_address: "invalid@example.com", password: "wrongpassword" }
    assert_redirected_to new_session_path
    assert_equal I18n.t("controllers.sessions.create.invalid_credentials"), flash[:alert]
  end

  test "should allow unauthenticated access to create action with valid credentials" do
    user = users(:user_one)

    post session_url, params: { email_address: user.email_address, password: "password" }
    assert_redirected_to root_path
  end

  test "should redirect authenticated user away from new action" do
    user = users(:user_one)
    sign_in_as(user)

    get new_session_url
    assert_redirected_to root_path
  end

  test "should redirect authenticated user away from create action" do
    user = users(:user_one)
    sign_in_as(user)

    post session_url, params: { email_address: user.email_address, password: "password" }
    assert_redirected_to root_path
  end

  test "should allow authenticated user to access destroy action" do
    user = users(:user_one)
    sign_in_as(user)

    delete session_url
    assert_redirected_to root_path
  end

  test "should destroy session and redirect to root" do
    user = users(:user_one)
    sign_in_as(user)

    # Verify user is signed in
    get new_session_url
    assert_redirected_to root_path

    # Sign out
    delete session_url
    assert_redirected_to root_path

    # Verify user is signed out by checking they can access new session page
    get new_session_url
    assert_response :success
  end
end
