require "test_helper"

module GeoTerms
  class NominatimSearchJobTest < ActiveJob::TestCase
    test "should return early when search_term is blank" do
      assert_no_changes -> { GeoTerm.count } do
        NominatimSearchJob.perform_now("")
      end
    end

    test "should return early when search_term is nil" do
      assert_no_changes -> { GeoTerm.count } do
        NominatimSearchJob.perform_now(nil)
      end
    end

    test "should return early when GeoTerm already exists" do
      geo_term = GeoTerm.create!(
        term: "toronto",
        parsed_response: { "results" => [] }
      )

      Geocoder.expects(:search).never

      assert_no_changes -> { GeoTerm.count } do
        NominatimSearchJob.perform_now("toronto")
      end

      assert_equal geo_term, GeoTerm.find_by(term: "toronto")
    end

    test "should return early when GeoTerm exists with different case/whitespace" do
      geo_term = GeoTerm.create!(
        term: "toronto",
        parsed_response: [{ "old" => "data" }]
      )

      Geocoder.expects(:search).never

      assert_no_changes -> { GeoTerm.count } do
        NominatimSearchJob.perform_now("  TORONTO  ")
      end

      geo_term.reload
      assert_equal [{ "old" => "data" }], geo_term.parsed_response
    end

    test "should perform search and save geo term with single result" do
      address = "123 Main St, Toronto, ON",
      latitude = 43.6532,
      longitude = -79.3832,
      coordinates = [43.6532, -79.3832],
      city = "Toronto",
      state = "Ontario",
      state_code = "ON",
      country = "Canada",
      country_code = "CA"

      result = mock_geocoder_result(
        address:,
        latitude:,
        longitude:,
        coordinates:,
        city:,
        state:,
        state_code:,
        country:,
        country_code:
      )

      Geocoder.expects(:search).with("toronto", lookup: :nominatim).returns([result])

      assert_difference -> { GeoTerm.count }, 1 do
        NominatimSearchJob.perform_now("toronto")
      end

      geo_term = GeoTerm.find_by(term: "toronto")
      parsed_response = geo_term.parsed_response
      parsed_response_first = parsed_response.first

      assert_not_nil geo_term
      assert_equal 1, parsed_response.length
      assert_equal address, parsed_response_first["address"]
      assert_equal latitude, parsed_response_first["latitude"]
      assert_equal longitude, parsed_response_first["longitude"]
      assert_equal city, parsed_response_first["city"]
      assert_equal state, parsed_response_first["state"]
      assert_equal state_code, parsed_response_first["state_code"]
      assert_equal country, parsed_response_first["country"]
      assert_equal country_code, parsed_response_first["country_code"]
    end

    test "should perform search and save geo term with multiple results" do
      result1 = mock_geocoder_result(
        address: "Toronto",
        city: "Toronto",
        state: "Ontario",
        country: "Canada"
      )
      result2 = mock_geocoder_result(
        address: "Montreal",
        city: "Montreal",
        state: "Quebec",
        country: "Canada"
      )

      Geocoder.expects(:search).with("canada", lookup: :nominatim).returns([result1, result2])

      assert_difference -> { GeoTerm.count }, 1 do
        NominatimSearchJob.perform_now("canada")
      end

      geo_term = GeoTerm.find_by(term: "canada")
      assert_not_nil geo_term
      assert_equal 2, geo_term.parsed_response.length
      assert_equal "Toronto", geo_term.parsed_response.first["city"]
      assert_equal "Montreal", geo_term.parsed_response.second["city"]
    end

    test "should normalize search term before saving" do
      result = mock_geocoder_result(city: "Toronto")

      Geocoder.expects(:search).with("  TORONTO  ", lookup: :nominatim).returns([result])

      assert_difference -> { GeoTerm.count }, 1 do
        NominatimSearchJob.perform_now("  TORONTO  ")
      end

      geo_term = GeoTerm.find_by(term: "toronto")
      assert_not_nil geo_term
      assert_equal "toronto", geo_term.term
    end

    # @todo review
    test "should raise RecordInvalid when search results are empty" do
      Geocoder.expects(:search).with("nonexistent", lookup: :nominatim).returns([])

      assert_raises(ActiveRecord::RecordInvalid) do
        NominatimSearchJob.perform_now("nonexistent")
      end

      assert_nil GeoTerm.find_by(term: "nonexistent")
    end

    # @todo review
    test "should raise RecordInvalid when search results are nil" do
      Geocoder.expects(:search).with("nonexistent", lookup: :nominatim).returns(nil)

      assert_raises(ActiveRecord::RecordInvalid) do
        NominatimSearchJob.perform_now("nonexistent")
      end

      assert_nil GeoTerm.find_by(term: "nonexistent")
    end

    test "should use nominatim lookup" do
      result = mock_geocoder_result(city: "Toronto")

      Geocoder.expects(:search).with("toronto", lookup: :nominatim).returns([result])
      NominatimSearchJob.perform_now("toronto")
    end

    test "should handle results with nil values" do
      result = mock_geocoder_result(
        address: "Toronto",
        city: nil,
        state: nil,
        country: "Canada"
      )

      Geocoder.expects(:search).with("toronto", lookup: :nominatim).returns([result])

      assert_difference -> { GeoTerm.count }, 1 do
        NominatimSearchJob.perform_now("toronto")
      end

      geo_term = GeoTerm.find_by(term: "toronto")
      assert_not_nil geo_term
      assert_equal "Toronto", geo_term.parsed_response.first["address"]
      assert_nil geo_term.parsed_response.first["city"]
      assert_nil geo_term.parsed_response.first["state"]
      assert_equal "Canada", geo_term.parsed_response.first["country"]
    end

    test "should queue job in geocoder_search queue" do
      assert_equal "geocoder_search", NominatimSearchJob.queue_name
    end

    private
      def mock_geocoder_result(attributes = {})
        defaults = GeocoderResultFormatter::RESULT_KEYS.index_with(nil)
        stub(defaults.merge(attributes))
      end
  end
end
