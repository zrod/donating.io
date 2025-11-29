module GeoTerms
  class NominatimSearchJob < BaseSearchJob
    limits_concurrency key: ->(job) { job.class.name }, to: 1, duration: 1.second

    # @todo handle exceptions
    def perform(search_term)
      return if search_term.blank? || GeoTerm.exists?(term: search_term)

      results = Geocoder.search(search_term, lookup: :nominatim)
      parsed_response = format_results(results)
      save_geo_term(search_term, parsed_response)
    end
  end
end
