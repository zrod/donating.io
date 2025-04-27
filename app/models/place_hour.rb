class PlaceHour < ApplicationRecord
  belongs_to :place

  validate :from_lower_than_to

  validates :day,
            presence: true,
            numericality: { greater_than: 0, less_than: 8 }

  validates :from_hour,
            presence: true,
            format: { with: /\A[+-]?\d+\z/, message: I18n.t("activerecord.attributes.place_hour.from_hour_format") },
            numericality: { greater_than: -0.1, less_than: 2331, message: I18n.t("activerecord.attributes.place_hour.from_hour_range") }

  validates :to_hour,
            presence: true,
            format: { with: /\A[+-]?\d+\z/, message: I18n.t("activerecord.attributes.place_hour.to_hour_format") },
            numericality: { greater_than: 29, less_than: 2401, message: I18n.t("activerecord.attributes.place_hour.to_hour_range") }

  default_scope { order("day ASC") }

  def key
    [ from_hour, to_hour, day.to_s ].compact.join("")
  end

  private
    def from_lower_than_to
      unless from_hour.to_i < to_hour.to_i
        errors.add(:from_hour, I18n.t("activerecord.attributes.place_hour.from_hour_must_be_lower_than_to_hour"))
      end
    end
end
