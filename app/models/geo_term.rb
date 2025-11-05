class GeoTerm < ApplicationRecord
  validates :url, presence: true

  def response
    value = read_attribute(:response)
    return nil if value.nil?

    convert_to_indifferent(value)
  end

  def response=(value)
    write_attribute(:response, value)
  end

  class << self
    def [](url)
      find_by(url:)&.response
    end

    def []=(url, value)
      record = find_or_initialize_by(url:)
      record.response = value
      record.save!
      value
    end

    def keys
      pluck(:url)
    end

    def delete(url)
      record = find_by(url:)
      return nil unless record

      response = record.response
      record.destroy
      response
    end
  end

  private
    def convert_to_indifferent(value)
      case value
      when Hash
        ActiveSupport::HashWithIndifferentAccess.new(value)
      when Array
        value.map { |item| convert_to_indifferent(item) }
      else
        value
      end
    end
end
