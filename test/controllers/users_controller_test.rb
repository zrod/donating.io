require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  username = "testuser"
  email_address = "test@example.com"
  password = "password123"

  test "should get new" do
    get new_user_url
    assert_response :success
    assert_select "form"
  end

  test "should create user with valid attributes" do
    assert_difference("User.count") do
      post user_url, params: {
        user: {
          username:,
          email_address:,
          password:,
          password_confirmation: password
        }
      }
    end

    assert_redirected_to root_path
    assert_equal I18n.t("views.users.create.success"), flash[:notice]
  end

  test "should not create user with invalid attributes" do
    assert_no_difference("User.count") do
      post user_url, params: {
        user: {
          username: "",
          email_address: "invalid-email",
          password: "short",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user with password confirmation mismatch" do
    assert_no_difference("User.count") do
      post user_url, params: {
        user: {
          username:,
          email_address:,
          password:,
          password_confirmation: "different_password"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # Honeypot validation tests
  test "should redirect to root when honeypot field is filled (bot detection)" do
    assert_no_difference("User.count") do
      post user_url, params: {
        user: {
          username:,
          email_address:,
          password:,
          password_confirmation: password,
          url: "http://spam.com"
        }
      }
    end

    assert_redirected_to root_path
    assert_nil flash[:notice]
  end

  test "should create user when honeypot field is empty (human user)" do
    assert_difference("User.count") do
      post user_url, params: {
        user: {
          username:,
          email_address:,
          password:,
          password_confirmation: password,
          url: ""
        }
      }
    end

    assert_redirected_to root_path
    assert_equal I18n.t("views.users.create.success"), flash[:notice]
  end

  test "should create user when honeypot field is not present" do
    assert_difference("User.count") do
      post user_url, params: {
        user: {
          username:,
          email_address:,
          password:,
          password_confirmation: password
        }
      }
    end

    assert_redirected_to root_path
    assert_equal I18n.t("views.users.create.success"), flash[:notice]
  end

  # Tests for edit and update actions
  test "should redirect to login when trying to access edit without authentication" do
    get edit_user_url
    assert_redirected_to new_session_path
  end

  test "should redirect to login when trying to update without authentication" do
    patch user_url, params: {
      user: {
        username: "updated_username",
        email_address: "updated@example.com"
      }
    }
    assert_redirected_to new_session_path
  end

  test "should allow unauthenticated access to new" do
    get new_user_url
    assert_response :success
  end

  test "should allow unauthenticated access to create" do
    post user_url, params: {
      user: {
        username:,
        email_address:,
        password:,
        password_confirmation: password
      }
    }
    assert_response :redirect
  end
end
