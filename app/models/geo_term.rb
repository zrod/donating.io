class GeoTerm < ApplicationRecord
  validates :term, presence: true, uniqueness: true
  validates :response, presence: true

  before_save { self.term = term.parameterize }

  def self.save!(term:, response:)
    record = GeoTerm.find_or_initialize_by(term: term.parameterize)
    record.response = response
    record.save!
    record
  end
end
