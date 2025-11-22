module GeoTerms
  class NominatimSearchJob < BaseSearchJob
    limits_concurrency key: ->(job) { job.class.name }, to: 1, duration: 1.second

    SUPPRESS_RETRY = [
      ActiveRecord::RecordInvalid
    ].freeze

    def perform(search_term)
      # @todo handle exceptions
      return if search_term.blank?

      response = Geocoder.search(search_term, lookup: :nominatim)
      parsed_response = parser.new(response).call

      save_geo_term(search_term, parsed_response)
    end

    private
      def parser
        Nominatim::Parsers::SearchResultParser
      end
  end
end
