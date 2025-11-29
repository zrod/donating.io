class GeoTerm < ApplicationRecord
  TERM_MAX_LENGTH = 255

  normalizes :term, with: ->(t) { t.strip.downcase }

  validates :term, presence: true, uniqueness: true, length: { maximum: TERM_MAX_LENGTH }
  validates :parsed_response, exclusion: { in: [nil] }

  def self.normalize_term(term)
    return nil unless term.present?

    new(term:).term
  end
end
