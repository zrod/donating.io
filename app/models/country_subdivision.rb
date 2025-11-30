class CountrySubdivision < ApplicationRecord
  belongs_to :country, touch: true

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :country_id }
end
