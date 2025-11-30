module GeoTerms
  class PhotonSearchJob < BaseSearchJob
    limits_concurrency key: ->(job) { job.class.name }, to: 1, duration: 1.second

    protected
      def lookup_provider
        :photon
      end
  end
end
