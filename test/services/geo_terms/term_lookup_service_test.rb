require "test_helper"

module GeoTerms
  class TermLookupServiceTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test "should raise BlankSearchTermError when term is blank" do
      assert_raises(TermLookupService::BlankSearchTermError) do
        TermLookupService.new(term: "")
      end
    end

    test "should raise BlankSearchTermError when term is nil" do
      assert_raises(TermLookupService::BlankSearchTermError) do
        TermLookupService.new(term: nil)
      end
    end

    test "should normalize term during initialization" do
      service = TermLookupService.new(term: "  TEST TERM  ")

      assert_equal "test term", service.term
    end

    test "should return matching term when it exists" do
      geo_term = GeoTerm.create!(
        term: "toronto",
        parsed_response: { "results" => [{ "name" => "Toronto" }] }
      )

      service = TermLookupService.new(term: "Toronto")
      result = service.call

      assert_equal geo_term, result
      assert_no_enqueued_jobs
    end

    test "should return matching term when it exists regardless of case" do
      geo_term = GeoTerm.create!(
        term: "toronto",
        parsed_response: { "results" => [{ "name" => "Toronto" }] }
      )

      service = TermLookupService.new(term: "TORONTO")
      result = service.call

      assert_equal geo_term, result
      assert_no_enqueued_jobs
    end

    test "should return :failed when search job has failed" do
      service = TermLookupService.new(term: "new york")

      with_failed_search_job do
        result = service.call

        assert_equal :failed, result
        assert_no_enqueued_jobs
      end
    end

    test "should enqueue job and return nil when matching term does not exist" do
      service = TermLookupService.new(term: "New York")

      with_no_failed_search_jobs do
        assert_enqueued_with(job: NominatimSearchJob, args: ["new york"]) do
          result = service.call
          assert_nil result
        end
      end
    end

    test "should enqueue job with normalized term" do
      service = TermLookupService.new(term: "  NEW YORK  ")

      with_no_failed_search_jobs do
        assert_enqueued_with(job: NominatimSearchJob, args: ["new york"]) do
          service.call
        end
      end
    end
  end
end
