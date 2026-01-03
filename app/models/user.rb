class User < ApplicationRecord
  COMMUNITY_USER_USERNAME = "community".freeze
  COMMUNITY_USER_EMAIL = "community@localhost".freeze

  USERNAME_MIN_LENGTH = 3
  USERNAME_MAX_LENGTH = 20
  USERNAME_BLACKLIST = [
    "admin",
    "administrator",
    "staff",
    "user",
    COMMUNITY_USER_USERNAME
  ].freeze

  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :places, dependent: :destroy
  has_many :place_feedbacks, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :username, with: ->(u) { u.strip.downcase }

  validates :username,
            presence: true,
            uniqueness: true,
            format: {
              with: /\A[a-zA-Z0-9_.]+\z/s,
              message: I18n.t("models.user.invalid_username_format")
            },
            exclusion: {
              in: ->(user) { user.creating_community_user? ? [] : USERNAME_BLACKLIST },
              message: I18n.t("models.user.reserved_username")
            },
            length: {
              minimum: USERNAME_MIN_LENGTH,
              maximum: USERNAME_MAX_LENGTH,
              message: I18n.t("models.user.username_length", min: USERNAME_MIN_LENGTH, max: USERNAME_MAX_LENGTH)
            }

  validates :email_address, presence: true, email: true, uniqueness: true

  before_destroy :prevent_community_user_deletion

  attr_accessor :creating_community_user

  # Placeholder user for orphaned contributions
  def self.community_user
    find_or_create_by!(username: COMMUNITY_USER_USERNAME) do |user|
      user.creating_community_user = true
      user.email_address = COMMUNITY_USER_EMAIL
      user.password = SecureRandom.hex(32)
      user.password_confirmation = user.password
    end
  end

  def community_user?
    username == COMMUNITY_USER_USERNAME
  end

  def creating_community_user?
    creating_community_user == true
  end

  def schedule_for_deletion
    update_columns(email_address: [email_address, "_pending_delete"].join)
  end

  private
    def prevent_community_user_deletion
      if community_user?
        errors.add(:base, "Community user cannot be deleted")
        throw :abort
      end
    end
end
