module GeoTerms
  class TermLookupService
    class BlankSearchTermError < StandardError; end
    attr_reader :term

    def initialize(term:)
      raise BlankSearchTermError if term.blank?

      @term = GeoTerm.normalize_term(term)
    end

    def call
      matching_term = GeoTerm.find_by(term:)
      return matching_term if matching_term
      return :failed if search_job_failed?

      enqueue_search_job
      nil
    end

    private
      def search_provider_job
        NominatimSearchJob
      end

      def search_job_failed?
        job_class_name = search_provider_job.name
        arguments_json = [term].to_json

        SolidQueue::FailedExecution
          .joins(:job)
          .where(solid_queue_jobs: { class_name: job_class_name })
          .where("solid_queue_jobs.arguments = ?", arguments_json)
          .exists?
      end

      def enqueue_search_job
        cache_key = "geo_term_search_queued:#{Digest::SHA256.hexdigest(term)}"

        Rails.cache.fetch(cache_key, expires_in: 2.minutes) do
          search_provider_job.perform_later(term)
          true
        end
      end
  end
end
