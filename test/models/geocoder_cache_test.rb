require "test_helper"

class GeocoderCacheTest < ActiveSupport::TestCase
  def setup
    @test_url = "https://nominatim.openstreetmap.org/search?q=New+York+City&format=json"
    @test_data = [
      {
        "lat" => "40.7128",
        "lon" => "-74.0060",
        "display_name" => "New York, NY, USA"
      }
    ].as_json
  end

  # Validation tests
  test "should be valid with valid attributes" do
    geo_term = GeocoderCache.new(url: @test_url, response: @test_data)
    assert geo_term.valid?, geo_term.errors.full_messages.to_sentence
  end

  test "should require url" do
    geo_term = GeocoderCache.new(response: @test_data)
    assert_not geo_term.valid?
    assert_includes geo_term.errors[:url], "can't be blank"
  end

  test "should validate uniqueness of url" do
    GeocoderCache[@test_url] = @test_data
    duplicate = GeocoderCache.new(url: @test_url, response: { "different" => "data" })
    assert duplicate.valid?
    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate.save!
    end
  end

  test "[] should return nil for non-existent url" do
    assert_nil GeocoderCache["non-existent-url"]
  end

  test "[] should return cached data for existing url" do
    GeocoderCache[@test_url] = @test_data
    retrieved = GeocoderCache[@test_url]
    assert_equal @test_data, retrieved
    assert_kind_of ActiveSupport::HashWithIndifferentAccess, retrieved.first if retrieved.is_a?(Array)
  end

  test "[] should return data with indifferent access" do
    data = { "key" => "value", "nested" => { "inner" => "data" } }
    GeocoderCache[@test_url] = data
    retrieved = GeocoderCache[@test_url]
    assert_equal "value", retrieved["key"]
    assert_equal "value", retrieved[:key]
  end

  test "[]= should create new record if url doesn't exist" do
    assert_difference "GeocoderCache.count", 1 do
      GeocoderCache[@test_url] = @test_data
    end

    assert_equal @test_data, GeocoderCache[@test_url]
  end

  test "[]= should update existing record if url exists" do
    GeocoderCache[@test_url] = @test_data
    new_data = { "updated" => true, "lat" => "40.7128" }

    assert_no_difference "GeocoderCache.count" do
      GeocoderCache[@test_url] = new_data
    end

    assert_equal new_data, GeocoderCache[@test_url]
  end

  test "[]= should return the stored value" do
    result = GeocoderCache[@test_url] = @test_data
    assert_equal @test_data, result
  end

  test "[]= should handle array data" do
    array_data = [{ "lat" => "40.7128" }, { "lat" => "40.7129" }]
    GeocoderCache[@test_url] = array_data
    retrieved = GeocoderCache[@test_url]
    assert_equal array_data.length, retrieved.length
    assert_equal "40.7128", retrieved.first["lat"]
  end

  test "[]= should handle nested hash data" do
    nested_data = {
      "results" => [
        { "geometry" => { "lat" => 40.7128, "lng" => -74.0060 } }
      ]
    }

    GeocoderCache[@test_url] = nested_data
    retrieved = GeocoderCache[@test_url]
    assert_equal 40.7128, retrieved["results"].first["geometry"]["lat"]
    assert_equal 40.7128, retrieved[:results].first[:geometry][:lat]
  end

  test "keys should return empty array when no records exist" do
    assert_equal [], GeocoderCache.keys
  end

  test "keys should return all urls" do
    url1 = "https://example.com/search?q=test1"
    url2 = "https://example.com/search?q=test2"
    url3 = "https://example.com/search?q=test3"

    GeocoderCache[url1] = { "data" => "1" }
    GeocoderCache[url2] = { "data" => "2" }
    GeocoderCache[url3] = { "data" => "3" }

    keys = GeocoderCache.keys
    assert_includes keys, url1
    assert_includes keys, url2
    assert_includes keys, url3
    assert_equal 3, keys.length
  end

  test "delete should return nil for non-existent url" do
    assert_nil GeocoderCache.delete("non-existent-url")
  end

  test "delete should remove record and return data" do
    GeocoderCache[@test_url] = @test_data

    assert_difference "GeocoderCache.count", -1 do
      deleted_data = GeocoderCache.delete(@test_url)
      assert_equal @test_data, deleted_data
    end

    assert_nil GeocoderCache[@test_url]
  end

  test "delete should return nil after deletion" do
    GeocoderCache[@test_url] = @test_data
    GeocoderCache.delete(@test_url)
    assert_nil GeocoderCache.delete(@test_url)
  end

  test "should serialize and deserialize data correctly" do
    complex_data = {
      "string" => "value",
      "number" => 123,
      "boolean" => true,
      "array" => [1, 2, 3],
      "nested" => { "key" => "value" }
    }

    GeocoderCache[@test_url] = complex_data
    record = GeocoderCache.find_by(url: @test_url)

    assert_equal complex_data, record.response
    assert_equal "value", record.response["string"]
    assert_equal "value", record.response[:string]
    assert_equal 123, record.response["number"]
    assert_equal true, record.response["boolean"]
  end

  test "should handle nil data gracefully" do
    empty_data = {}
    GeocoderCache[@test_url] = empty_data
    retrieved = GeocoderCache[@test_url]
    assert_equal empty_data, retrieved
  end

  test "should work with Geocoder cache interface" do
    url1 = "geocoder:https://nominatim.openstreetmap.org/search?q=Paris"
    url2 = "geocoder:https://nominatim.openstreetmap.org/search?q=London"

    data1 = [{ "lat" => "48.8566", "lon" => "2.3522" }]
    data2 = [{ "lat" => "51.5074", "lon" => "-0.1278" }]

    GeocoderCache[url1] = data1
    GeocoderCache[url2] = data2

    assert_equal data1, GeocoderCache[url1]
    assert_equal data2, GeocoderCache[url2]

    assert_includes GeocoderCache.keys, url1
    assert_includes GeocoderCache.keys, url2

    GeocoderCache.delete(url1)
    assert_nil GeocoderCache[url1]
    assert_equal data2, GeocoderCache[url2]
  end

  test "should handle very long urls" do
    long_url = "https://example.com/search?" + ("q=test&" * 100) + "format=json"
    GeocoderCache[long_url] = @test_data
    assert_equal @test_data, GeocoderCache[long_url]
  end

  test "should handle special characters in url" do
    special_url = "https://example.com/search?q=test+with+spaces&amp=encoded"
    GeocoderCache[special_url] = @test_data
    assert_equal @test_data, GeocoderCache[special_url]
  end

  test "should handle unicode characters in data" do
    unicode_data = {
      "city" => "São Paulo",
      "country" => "Brasil",
      "description" => "São Paulo é uma cidade"
    }

    GeocoderCache[@test_url] = unicode_data
    retrieved = GeocoderCache[@test_url]
    assert_equal "São Paulo", retrieved["city"]
    assert_equal "Brasil", retrieved[:country]
  end
end
