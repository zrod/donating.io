class User < ApplicationRecord
  USERNAME_MIN_LENGTH = 3
  USERNAME_MAX_LENGTH = 20
  USERNAME_BLACKLIST = %w[
    admin
    administrator
    staff
    user
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
              in: USERNAME_BLACKLIST,
              message: I18n.t("models.user.reserved_username")
            },
            length: {
              minimum: USERNAME_MIN_LENGTH,
              maximum: USERNAME_MAX_LENGTH,
              message: I18n.t("models.user.username_length", min: USERNAME_MIN_LENGTH, max: USERNAME_MAX_LENGTH)
            }

  validates :email_address, presence: true, email: true, uniqueness: true
end
