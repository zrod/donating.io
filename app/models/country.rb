class Country < ApplicationRecord
  has_many :places, dependent: :nullify

  validates :name, presence: true
  validates :iso_alpha3, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :by_weight, -> { order(weight: :desc) }
end
