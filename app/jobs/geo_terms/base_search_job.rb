module GeoTerms
  class BaseSearchJob < ApplicationJob
    class BlankSearchTermError < StandardError; end

    queue_as :geocoder_search

    protected
      # @todo handle exceptions
      def save_geo_term(search_term, parsed_response)
        geo_term = GeoTerm.find_or_initialize_by(term: search_term)
        geo_term.parsed_response = parsed_response || []
        geo_term.save!
      end
  end
end
