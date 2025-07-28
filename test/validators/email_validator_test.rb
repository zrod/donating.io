require "test_helper"

class EmailValidatorTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::Validations
    attr_accessor :email_address

    validates :email_address, email: true

    def initialize(email_address = nil)
      @email_address = email_address
    end
  end

  def setup
    @model = TestModel.new
  end

  test "should accept valid email formats" do
    valid_emails = [
      "test@example.com",
      "user.name@example.com",
      "user+tag@example.com",
      "user123@example.org",
      "firstname.lastname@example.net",
      "user@subdomain.example.com"
    ]

    valid_emails.each do |email|
      @model.email_address = email
      assert @model.valid?, "#{email} should be valid but got errors: #{@model.errors.full_messages}"
    end
  end

  test "should reject invalid email formats" do
    invalid_emails = [
      "plainaddress",
      "@example.com",
      "user@",
      "user@.com",
      "user@example.",
      "user name@example.com"
    ]

    invalid_emails.each do |email|
      @model.email_address = email
      refute @model.valid?, "#{email} should be invalid"
      assert_includes @model.errors[:email_address], "is invalid"
    end
  end

  test "should reject nil email" do
    @model.email_address = nil
    refute @model.valid?
    assert_includes @model.errors[:email_address], "is invalid"
  end

  test "should reject blank email" do
    @model.email_address = ""
    refute @model.valid?
    assert_includes @model.errors[:email_address], "is invalid"
  end

  test "should reject whitespace-only email" do
    @model.email_address = "   "
    refute @model.valid?
    assert_includes @model.errors[:email_address], "is invalid"
  end

  test "should accept popular providers with correct TLDs" do
    valid_popular_emails = EmailValidator::POPULAR_PROVIDERS.sample(6).map { |provider| "user@#{provider}.com" }

    valid_popular_emails.each do |email|
      @model.email_address = email
      assert @model.valid?, "#{email} should be valid but got errors: #{@model.errors.full_messages}"
    end
  end

  test "should reject popular providers with common TLD typos" do
    bad_tld_emails = EmailValidator::POPULAR_PROVIDERS.zip(EmailValidator::BAD_TLD_VARIATIONS).map do |provider, bad_tld|
      "user@#{provider}.#{bad_tld}"
    end

    bad_tld_emails.each do |email|
      @model.email_address = email
      refute @model.valid?, "#{email} should be invalid"
      assert_includes @model.errors[:email_address], "is invalid"
    end
  end

  test "should accept non-popular providers even with bad TLD variations" do
    non_popular_emails = [
      "user@example.comn",
      "user@company.con",
      "user@business.cmo"
    ]

    non_popular_emails.each do |email|
      @model.email_address = email
      assert @model.valid?, "#{email} should be valid for non-popular providers"
    end
  end

  test "should handle emails without proper domain structure" do
    malformed_emails = [
      "user@",
      "user@.",
      "@domain.com",
      "user@@domain.com"
    ]

    malformed_emails.each do |email|
      @model.email_address = email
      refute @model.valid?, "#{email} should be invalid"
      assert_includes @model.errors[:email_address], "is invalid"
    end
  end

  test "should use custom error message when provided" do
    custom_model_class = Class.new do
      include ActiveModel::Validations
      attr_accessor :email_address

      validates :email_address, email: { message: "has an invalid format" }
    end

    custom_model = custom_model_class.new
    custom_model.email_address = "invalid"
    refute custom_model.valid?
    assert_includes custom_model.errors[:email_address], "has an invalid format"
  end
end
