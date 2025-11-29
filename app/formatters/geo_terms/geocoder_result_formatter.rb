module GeoTerms
  class GeocoderResultFormatter
    RESULT_KEYS = %i[
      address
      latitude
      longitude
      coordinates
      city
      state
      state_code
      country
      country_code
    ].freeze

    def self.format(results)
      return [] if results.blank?

      results.map do |result|
        RESULT_KEYS.each_with_object({}) do |key, memo|
          memo[key] = result.public_send(key)
        end
      end
    end
  end
end
