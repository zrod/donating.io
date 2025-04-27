class Place < ApplicationRecord
  STATUSES = {
    pending: 0,
    published: 1,
    removed: 2
  }.freeze

  belongs_to :user
  belongs_to :country

  has_many :categories_places, dependent: :destroy
  has_many :categories, through: :categories_places, dependent: :destroy
  has_many :place_hours, dependent: :destroy
  has_many :place_feedbacks, dependent: :destroy

  accepts_nested_attributes_for :categories_places, allow_destroy: true
  accepts_nested_attributes_for :place_hours, allow_destroy: true

  scope :published, -> { where(status: STATUSES[:published]) }

  reverse_geocoded_by :lat, :lng

  before_create { self.status = STATUSES[:pending] }
  before_save   { self.slug = (name + lat.to_s + lng.to_s).parameterize }

  validates :name,                presence: true, length: { minimum: 4 }
  validates :categories_places,   presence: true
  validates :description,         presence: true
  validates :email,               email: true, allow_blank: true
  validates :address,             presence: true, length: { minimum: 6 }
  validates :postal_code,         length: { maximum: 12 }
  validates :city,                presence: true, length: { minimum: 3 }
  validates :lat,                 presence: true
  validates :lng,                 presence: true
  validates :pickup,              inclusion: { in: [ true, false ] }
  validates :used_ok,             inclusion: { in: [ true, false ] }

  validates_associated :categories

  def full_address
    [ address, city, region, postal_code, country.name ].compact.join(", ")
  end

  def geo_location
    "#{lat},#{lng}"
  end

  def has_charity_support
    charity_support.present?
  end
end
