module GeoTerms
  class BaseSearchJob < ApplicationJob
    queue_as :geocoder_search

    def perform(search_term)
      return if search_term.blank? || GeoTerm.exists?(term: search_term)

      results = Geocoder.search(search_term, lookup: lookup_provider)
      parsed_response = format_results(results)
      save_geo_term(search_term, parsed_response)
    end

    protected
      def lookup_provider
        raise NoMethodError, "Not implemented by base class."
      end

      def format_results(results)
        return [] if results.blank?

        GeocoderResultFormatter.format(results)
      end

      # @todo handle exceptions
      def save_geo_term(search_term, parsed_response)
        normalized_term = GeoTerm.normalize_term(search_term)

        geo_term = GeoTerm.find_or_initialize_by(term: normalized_term)
        geo_term.parsed_response = parsed_response
        geo_term.save!
      end
  end
end
