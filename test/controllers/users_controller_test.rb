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

    assert_response :unprocessable_content
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

    assert_response :unprocessable_content
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

  # Tests for update action
  test "should redirect to login when trying to update without authentication" do
    patch account_path, params: {
      user: {
        username: "newusername",
        email_address: "new@example.com",
        password: "password"
      }
    }
    assert_redirected_to new_session_path
  end

  test "should redirect to account path with alert when password is invalid" do
    user = users(:user_one)
    sign_in_as(user)

    patch account_path, params: {
      user: {
        username: "newusername",
        email_address: "new@example.com",
        password: "wrong_password"
      }
    }

    assert_redirected_to account_path
    assert_equal I18n.t("views.account.update.invalid_password"), flash[:alert]
  end

  test "should update username and email when password is valid" do
    user = users(:user_one)
    sign_in_as(user)
    original_username = user.username
    original_email = user.email_address

    patch account_path, params: {
      user: {
        username: "updatedusername",
        email_address: "updated@example.com",
        password: "password"
      }
    }

    user.reload
    assert_redirected_to account_path
    assert_equal I18n.t("views.account.update.success"), flash[:notice]
    assert_equal "updatedusername", user.username
    assert_equal "updated@example.com", user.email_address
    refute_equal original_username, user.username
    refute_equal original_email, user.email_address
  end

  test "should render account show with errors when username is invalid" do
    user = users(:user_one)
    original_username = user.username
    sign_in_as(user)

    patch account_path, params: {
      user: {
        username: "",
        email_address: user.email_address,
        password: "password"
      }
    }

    assert_response :unprocessable_content
    user.reload
    assert_equal original_username, user.username, "Username should not be updated when validation fails"
  end

  test "should render account show with errors when email is invalid" do
    user = users(:user_one)
    original_email = user.email_address
    sign_in_as(user)

    patch account_path, params: {
      user: {
        username: user.username,
        email_address: "invalid-email",
        password: "password"
      }
    }

    assert_response :unprocessable_content
    user.reload
    assert_equal original_email, user.email_address, "Email should not be updated when validation fails"
  end

  test "should render account show with errors when username is already taken" do
    user = users(:user_one)
    other_user = users(:user_two)
    original_username = user.username
    sign_in_as(user)

    patch account_path, params: {
      user: {
        username: other_user.username,
        email_address: user.email_address,
        password: "password"
      }
    }

    assert_response :unprocessable_content
    user.reload
    assert_equal original_username, user.username, "Username should not be updated when validation fails"
  end

  test "should render account show with errors when email is already taken" do
    user = users(:user_one)
    other_user = users(:user_two)
    original_email = user.email_address
    sign_in_as(user)

    patch account_path, params: {
      user: {
        username: user.username,
        email_address: other_user.email_address,
        password: "password"
      }
    }

    assert_response :unprocessable_content
    user.reload
    assert_equal original_email, user.email_address, "Email should not be updated when validation fails"
  end

  test "should not update password field when updating profile" do
    user = users(:user_one)
    sign_in_as(user)
    original_password_digest = user.password_digest

    patch account_path, params: {
      user: {
        username: user.username,
        email_address: "newemail@example.com",
        password: "password"
      }
    }

    user.reload
    assert_redirected_to account_path
    assert_equal original_password_digest, user.password_digest
  end

  # Tests for destroy action
  test "should redirect to login when trying to destroy without authentication" do
    delete user_url, params: { user: { password: "password" } }
    assert_redirected_to new_session_path
  end

  test "should redirect to account path with alert when password is invalid for destroy" do
    user = users(:user_one)
    sign_in_as(user)

    delete user_url, params: { user: { password: "wrong_password" } }

    assert_redirected_to account_path
    assert_equal I18n.t("views.users.destroy.invalid_password"), flash[:alert]
  end

  test "should schedule user for deletion when password is valid" do
    user = users(:user_one)
    original_email = user.email_address
    sign_in_as(user)

    delete user_url, params: { user: { password: "password" } }

    user.reload
    assert_equal "#{original_email}_pending_delete", user.email_address
  end

  test "should enqueue destroy user job when password is valid" do
    user = users(:user_one)
    sign_in_as(user)

    assert_enqueued_with(job: Users::DestroyUserJob) do
      delete user_url, params: { user: { password: "password" } }
    end
  end

  test "should enqueue destroy user job with keep_contributions false when not provided" do
    user = users(:user_one)
    sign_in_as(user)

    assert_enqueued_with(job: Users::DestroyUserJob, args: [user.id, false]) do
      delete user_url, params: { user: { password: "password" } }
    end
  end

  test "should enqueue destroy user job with keep_contributions true when keep_contributions is 1" do
    user = users(:user_one)
    sign_in_as(user)

    assert_enqueued_with(job: Users::DestroyUserJob, args: [user.id, true]) do
      delete user_url, params: { user: { password: "password" }, keep_contributions: "1" }
    end
  end

  test "should enqueue destroy user job with keep_contributions false when keep_contributions is not 1" do
    user = users(:user_one)
    sign_in_as(user)

    assert_enqueued_with(job: Users::DestroyUserJob, args: [user.id, false]) do
      delete user_url, params: { user: { password: "password" }, keep_contributions: "0" }
    end
  end

  test "should terminate session and redirect to root with success notice when password is valid" do
    user = users(:user_one)
    sign_in_as(user)

    delete user_url, params: { user: { password: "password" } }

    assert_redirected_to root_path
    assert_equal I18n.t("views.users.destroy.success"), flash[:notice]

    # Verify session is terminated by checking we can access login page
    get new_session_url
    assert_response :success
  end
end
