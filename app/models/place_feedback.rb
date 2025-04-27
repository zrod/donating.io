class PlaceFeedback < ApplicationRecord
  belongs_to :place

  validates :reason, presence: true

  VALID_REASONS = %w[
    incorrect_address
    closed
    no_longer_accepts_donations
    wrong_information
    other
  ].freeze
end
