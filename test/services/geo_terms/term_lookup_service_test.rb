require "test_helper"

module GeoTerms
  class TermLookupServiceTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test "should return nil when term is blank" do
      service = TermLookupService.new(term: "")
      result = service.call

      assert_nil result
      assert_no_enqueued_jobs
    end

    test "should return nil when term is nil" do
      service = TermLookupService.new(term: nil)
      result = service.call

      assert_nil result
      assert_no_enqueued_jobs
    end

    test "should normalize term during initialization" do
      service = TermLookupService.new(term: "  TEST TERM  ")

      assert_equal "test term", service.term
    end

    test "should return matching term when it exists with parsed_response" do
      geo_term = GeoTerm.create!(
        term: "toronto",
        parsed_response: { "results" => [{ "name" => "Toronto" }] }
      )

      service = TermLookupService.new(term: "Toronto")
      result = service.call

      assert_equal geo_term, result
      assert_no_enqueued_jobs
    end

    test "should return matching term when it exists with parsed_response regardless of case" do
      geo_term = GeoTerm.create!(
        term: "toronto",
        parsed_response: { "results" => [{ "name" => "Toronto" }] }
      )

      service = TermLookupService.new(term: "TORONTO")
      result = service.call

      assert_equal geo_term, result
      assert_no_enqueued_jobs
    end

    test "should enqueue job and return nil when matching term exists but parsed_response is empty array" do
      geo_term = GeoTerm.create!(
        term: "toronto",
        parsed_response: { "results" => [] }
      )
      # Update to empty array which will fail present? check
      geo_term.update_column(:parsed_response, [])

      service = TermLookupService.new(term: "Toronto")

      assert_enqueued_with(job: NominatimSearchJob, args: [geo_term.term]) do
        result = service.call
        assert_nil result
      end
    end

    test "should enqueue job and return nil when matching term does not exist" do
      service = TermLookupService.new(term: "New York")

      assert_enqueued_with(job: NominatimSearchJob, args: ["new york"]) do
        result = service.call
        assert_nil result
      end
    end

    test "should enqueue job with normalized term" do
      service = TermLookupService.new(term: "  NEW YORK  ")

      assert_enqueued_with(job: NominatimSearchJob, args: ["new york"]) do
        service.call
      end
    end

    test "should handle term with special characters" do
      service = TermLookupService.new(term: "São Paulo")

      assert_enqueued_with(job: NominatimSearchJob, args: ["são paulo"]) do
        service.call
      end
    end

    test "should handle term at maximum length" do
      long_term = "a" * GeoTerm::TERM_MAX_LENGTH
      service = TermLookupService.new(term: long_term)

      assert_enqueued_with(job: NominatimSearchJob, args: [long_term.downcase]) do
        service.call
      end
    end
  end
end
