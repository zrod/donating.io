ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    setup do
      Rails.cache.clear
    end

    # User auth helper
    def sign_in_as(user, password: "password")
      post session_url, params: { email_address: user.email_address, password: }
    end

    # Stub search_job_failed? to avoid needing queue database in tests
    def with_no_failed_search_jobs
      GeoTerms::TermLookupService.any_instance.stubs(:search_job_failed?).returns(false)
      yield
    end

    def with_failed_search_job
      GeoTerms::TermLookupService.any_instance.stubs(:search_job_failed?).returns(true)
      yield
    end
  end
end
