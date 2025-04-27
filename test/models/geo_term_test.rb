require "test_helper"

class GeoTermTest < ActiveSupport::TestCase
  def setup
    @geo_term = GeoTerm.new(
      term: "New York City",
      response: { "lat" => 40.7128, "lng" => -74.0060 }.to_json
    )
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @geo_term.valid?, @geo_term.errors.full_messages.to_sentence
  end

  test "should require term" do
    @geo_term.term = nil
    assert_not @geo_term.valid?
    assert_includes @geo_term.errors[:term], "can't be blank"
  end

  test "should require response" do
    @geo_term.response = nil
    assert_not @geo_term.valid?
    assert_includes @geo_term.errors[:response], "can't be blank"
  end

  test "should validate uniqueness of term" do
    @geo_term.save
    duplicate_term = GeoTerm.new(
      term: @geo_term.term,
      response: { "lat" => 40.7128, "lng" => -74.0060 }.to_json
    )
    assert_not duplicate_term.valid?
    assert_includes duplicate_term.errors[:term], "has already been taken"
  end

  # Callback tests
  test "should parameterize term before save" do
    @geo_term.term = "New York City"
    @geo_term.save
    assert_equal "new-york-city", @geo_term.term
  end

  test "should parameterize term with spaces and special characters" do
    @geo_term.term = "São Paulo, Brazil"
    @geo_term.save
    assert_equal "sao-paulo-brazil", @geo_term.term
  end

  # Class method tests
  test "save! should create new record if term doesn't exist" do
    term = "Los Angeles"
    response = { "lat" => 34.0522, "lng" => -118.2437 }.to_json

    assert_difference "GeoTerm.count", 1 do
      GeoTerm.save!(term: term, response: response)
    end

    geo_term = GeoTerm.find_by(term: "los-angeles")
    assert_equal response, geo_term.response
  end

  test "save! should update existing record if term exists" do
    @geo_term.save
    new_response = { "lat" => 40.7128, "lng" => -74.0060, "updated" => true }.to_json

    assert_no_difference "GeoTerm.count" do
      GeoTerm.save!(term: "New York City", response: new_response)
    end

    @geo_term.reload
    assert_equal new_response, @geo_term.response
  end

  test "save! should parameterize term when finding or initializing" do
    term = "San Francisco"
    parameterized_term = "san-francisco"
    response = { "lat" => 37.7749, "lng" => -122.4194 }.to_json

    GeoTerm.save!(term: term, response: response)
    geo_term = GeoTerm.find_by(term: parameterized_term)

    assert_equal parameterized_term, geo_term.term
    assert_equal response, geo_term.response
  end

  test "save! should return the record" do
    term = "Chicago"
    response = { "lat" => 41.8781, "lng" => -87.6298 }.to_json

    result = GeoTerm.save!(term: term, response: response)
    assert_instance_of GeoTerm, result
    assert_equal "chicago", result.term
    assert_equal response, result.response
  end
end
