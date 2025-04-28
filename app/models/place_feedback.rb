class PlaceFeedback < ApplicationRecord
  belongs_to :place
  belongs_to :user

  enum :reason, {
    incorrect_address: 0,
    closed: 1,
    no_longer_accepts_donations: 2,
    wrong_information: 3,
    other: 4
  }

  validates :reason, presence: true
end
