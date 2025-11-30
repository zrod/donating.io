class Country < ApplicationRecord
  has_many :country_subdivisions, dependent: :destroy
  has_many :places, dependent: :restrict_with_error

  validates :name, presence: true
  validates :iso_alpha3, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :by_weight, -> { order(weight: :desc) }
end
