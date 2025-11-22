module GeoTerms
  class TermLookupService
    attr_reader :term

    def initialize(term:)
      @term = GeoTerm.normalize_term(term)
    end

    def call
      return unless term.present?

      matching_term = GeoTerm.find_by(term:)
      return matching_term if matching_term&.parsed_response.present?

      search_provider_job.perform_later(term)
      nil
    end

    private
      def search_provider_job
        NominatimSearchJob
      end
  end
end
