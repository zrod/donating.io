require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @valid_attributes = {
      username: "testuser",
      email_address: "test@example.com",
      password: "password123"
    }
  end

  # Test valid user creation
  test "should create user with valid attributes" do
    user = User.new(@valid_attributes)
    assert user.valid?
    assert user.save
  end

  test "should authenticate user with correct password" do
    user = users(:user_one)
    assert user.authenticate("password")
    refute user.authenticate("wrong_password")
  end

  # Username presence validation tests
  test "should require username" do
    user = User.new(@valid_attributes.merge(username: nil))
    refute user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "should require username not to be empty string" do
    user = User.new(@valid_attributes.merge(username: ""))
    refute user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "should require username not to be whitespace only" do
    user = User.new(@valid_attributes.merge(username: "   "))
    refute user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  # Username uniqueness validation tests
  test "should require unique username" do
    existing_user = users(:user_one)
    duplicate_user = User.new(@valid_attributes.merge(
      username: existing_user.username,
      email_address: "different@example.com"
    ))
    refute duplicate_user.valid?
    assert_includes duplicate_user.errors[:username], "has already been taken"
  end

  test "should require unique username regardless of case" do
    existing_user = users(:user_one)
    duplicate_user = User.new(@valid_attributes.merge(
      username: existing_user.username.upcase,
      email_address: "different@example.com"
    ))
    refute duplicate_user.valid?
    assert_includes duplicate_user.errors[:username], "has already been taken"
  end

  # Username format validation tests
  test "should accept valid username formats" do
    valid_usernames = %w[
      user123
      test_user
      user.name
      UserName
      user_123.test
      a1_
      test.user.123
    ]

    valid_usernames.each do |username|
      user = User.new(@valid_attributes.merge(username:, email_address: "#{username}@example.com"))
      assert user.valid?, "#{username} should be valid but got errors: #{user.errors.full_messages}"
    end
  end

  test "should reject invalid username formats" do
    invalid_usernames_samples = [
      "user name",
      "user-name",
      "user@name"
    ]

    invalid_usernames_samples.each do |username|
      user = User.new(@valid_attributes.merge(username:, email_address: "#{username.gsub(/[^a-zA-Z0-9]/, '')}@example.com"))
      refute user.valid?, "#{username} should be invalid"
      assert_includes user.errors[:username], I18n.t("models.user.invalid_username_format")
    end
  end

  # Username blacklist validation tests
  test "should reject blacklisted usernames" do
    User::USERNAME_BLACKLIST.each do |blacklisted_username|
      user = User.new(@valid_attributes.merge(username: blacklisted_username, email_address: "#{blacklisted_username}@example.com"))
      refute user.valid?, "#{blacklisted_username} should be rejected"
      assert_includes user.errors[:username], I18n.t("models.user.reserved_username")
    end
  end

  # Username length validation tests
  test "should reject username shorter than minimum length" do
    short_username = "a" * (User::USERNAME_MIN_LENGTH - 1)
    user = User.new(@valid_attributes.merge(username: short_username))
    refute user.valid?
    assert_includes user.errors[:username], I18n.t("models.user.username_length", min: User::USERNAME_MIN_LENGTH, max: User::USERNAME_MAX_LENGTH)
  end

  test "should accept username at minimum length" do
    min_username = "a" * User::USERNAME_MIN_LENGTH
    user = User.new(@valid_attributes.merge(username: min_username))
    assert user.valid?
  end

  test "should accept username at maximum length" do
    max_username = "a" * User::USERNAME_MAX_LENGTH
    user = User.new(@valid_attributes.merge(username: max_username))
    assert user.valid?
  end

  test "should reject username longer than maximum length" do
    long_username = "a" * (User::USERNAME_MAX_LENGTH + 1)
    user = User.new(@valid_attributes.merge(username: long_username))
    refute user.valid?
    assert_includes user.errors[:username], I18n.t("models.user.username_length", min: User::USERNAME_MIN_LENGTH, max: User::USERNAME_MAX_LENGTH)
  end

  # Email presence validation tests
  test "should require email address" do
    user = User.new(@valid_attributes.merge(email_address: nil))
    refute user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "should require email address not to be empty string" do
    user = User.new(@valid_attributes.merge(email_address: ""))
    refute user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  # Email format validation tests (assuming custom email validator)
  test "should accept valid email formats" do
    valid_emails_samples = %w[
      test@example.com
      user.name@example.com
      user+tag@example.com
    ]

    valid_emails_samples.each do |email_address|
      user = User.new(@valid_attributes.merge(email_address:, username: "user#{valid_emails_samples.index(email_address)}"))
      assert user.valid?, "#{email_address} should be valid but got errors: #{user.errors.full_messages}"
    end
  end

  test "should reject invalid email formats" do
    invalid_emails_samples = [
      "plainaddress",
      "@missingdomain.com",
      "missing@.com"
    ]

    invalid_emails_samples.each do |email_address|
      user = User.new(@valid_attributes.merge(email_address:, username: "user#{invalid_emails_samples.index(email_address)}"))
      refute user.valid?, "#{email_address} should be invalid"
      assert_includes user.errors[:email_address], "is invalid"
    end
  end

  # Email uniqueness validation tests
  test "should require unique email address" do
    existing_user = users(:user_one)
    duplicate_user = User.new(@valid_attributes.merge(
      username: "different_user",
      email_address: existing_user.email_address
    ))
    refute duplicate_user.valid?
    assert_includes duplicate_user.errors[:email_address], "has already been taken"
  end

  # Password validation tests
  test "should require password" do
    user = User.new(@valid_attributes.merge(password: nil))
    refute user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "should require password not to be empty string" do
    user = User.new(@valid_attributes.merge(password: ""))
    refute user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "should accept valid password" do
    user = User.new(@valid_attributes.merge(password: "validpassword123"))
    assert user.valid?
  end

  # Normalization tests
  test "should normalize email address to lowercase and strip whitespace" do
    user = User.create(@valid_attributes.merge(email_address: "  Test@Example.COM  "))
    assert_equal "test@example.com", user.email_address
  end

  test "should normalize username to lowercase and strip whitespace" do
    user = User.create(@valid_attributes.merge(username: "  TestUser  ", email_address: "unique@example.com"))
    assert_equal "testuser", user.username
  end

  # Association tests
  test "should have many sessions" do
    user = users(:user_one)
    assert_respond_to user, :sessions
    assert_kind_of ActiveRecord::Associations::CollectionProxy, user.sessions
  end

  test "should have many places" do
    user = users(:user_one)
    assert_respond_to user, :places
    assert_kind_of ActiveRecord::Associations::CollectionProxy, user.places
  end

  test "should have many place_feedbacks" do
    user = users(:user_one)
    assert_respond_to user, :place_feedbacks
    assert_kind_of ActiveRecord::Associations::CollectionProxy, user.place_feedbacks
  end

  test "should destroy dependent sessions when user is destroyed" do
    user = users(:user_one)
    # This test assumes Session model exists and can be created
    # session = user.sessions.create(valid_session_attributes)
    # user.destroy
    # refute Session.exists?(session.id)

    # For now, just test the association is configured correctly
    association = User.reflect_on_association(:sessions)
    assert_equal :destroy, association.options[:dependent]
  end

  test "should destroy dependent places when user is destroyed" do
    association = User.reflect_on_association(:places)
    assert_equal :destroy, association.options[:dependent]
  end

  test "should destroy dependent place_feedbacks when user is destroyed" do
    association = User.reflect_on_association(:place_feedbacks)
    assert_equal :destroy, association.options[:dependent]
  end

  # Fixture-based tests
  test "fixtures should be valid" do
    assert users(:user_one).valid?
    assert users(:user_two).valid?
  end

  test "fixture users should have expected attributes" do
    user_one = users(:user_one)
    assert_equal "userone", user_one.username
    assert_equal "one@example.com", user_one.email_address

    user_two = users(:user_two)
    assert_equal "usertwo", user_two.username
    assert_equal "two@example.com", user_two.email_address
  end

  # Edge case tests
  test "should handle special characters in username" do
    special_username = "test*user"
    user = User.new(@valid_attributes.merge(username: special_username))
    refute user.valid?
    assert_includes user.errors[:username], I18n.t("models.user.invalid_username_format")
  end

  test "should handle very long email address" do
    long_email = "#{'a' * 50}@#{'b' * 50}.com"
    user = User.new(@valid_attributes.merge(email_address: long_email, username: "longtest"))
    assert user.valid?
  end

  test "should handle username with mixed case normalization" do
    user = User.new(@valid_attributes.merge(username: "TestUser123"))
    user.valid? # trigger normalization
    assert_equal "testuser123", user.username
  end

  # schedule_for_deletion tests
  test "should append _pending_delete to email address" do
    user = users(:user_one)
    original_email = user.email_address
    expected_email = "#{original_email}_pending_delete"

    user.schedule_for_deletion

    assert_equal expected_email, user.email_address
  end

  test "should persist email address change to database" do
    user = users(:user_one)
    original_email = user.email_address
    expected_email = "#{original_email}_pending_delete"

    user.schedule_for_deletion
    user.reload

    assert_equal expected_email, user.email_address
  end
end
