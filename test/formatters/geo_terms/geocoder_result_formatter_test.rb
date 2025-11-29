require "test_helper"

module GeoTerms
  class GeocoderResultFormatterTest < ActiveSupport::TestCase
    test "should return empty array when results are blank" do
      assert_equal [], GeocoderResultFormatter.format(nil)
      assert_equal [], GeocoderResultFormatter.format([])
    end

    test "should format single result" do
      result = mock_geocoder_result(
        address: "123 Main St, Toronto, ON",
        latitude: 43.6532,
        longitude: -79.3832,
        coordinates: [43.6532, -79.3832],
        city: "Toronto",
        state: "Ontario",
        state_code: "ON",
        country: "Canada",
        country_code: "CA"
      )

      formatted = GeocoderResultFormatter.format([result])

      assert_equal 1, formatted.length
      assert_equal "123 Main St, Toronto, ON", formatted.first[:address]
      assert_equal 43.6532, formatted.first[:latitude]
      assert_equal(-79.3832, formatted.first[:longitude])
      assert_equal [43.6532, -79.3832], formatted.first[:coordinates]
      assert_equal "Toronto", formatted.first[:city]
      assert_equal "Ontario", formatted.first[:state]
      assert_equal "ON", formatted.first[:state_code]
      assert_equal "Canada", formatted.first[:country]
      assert_equal "CA", formatted.first[:country_code]
    end

    test "should format multiple results" do
      result1 = mock_geocoder_result(address: "Toronto", city: "Toronto")
      result2 = mock_geocoder_result(address: "Montreal", city: "Montreal")

      formatted = GeocoderResultFormatter.format([result1, result2])

      assert_equal 2, formatted.length
      assert_equal "Toronto", formatted.first[:city]
      assert_equal "Montreal", formatted.second[:city]
    end

    test "should handle nil values in result" do
      result = mock_geocoder_result(
        address: "Toronto",
        city: nil,
        state: nil
      )

      formatted = GeocoderResultFormatter.format([result])

      assert_equal "Toronto", formatted.first[:address]
      assert_nil formatted.first[:city]
      assert_nil formatted.first[:state]
    end

    private
      def mock_geocoder_result(attributes = {})
        defaults = GeocoderResultFormatter::RESULT_KEYS.index_with(nil)
        stub(defaults.merge(attributes))
      end
  end
end
