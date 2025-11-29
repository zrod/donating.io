require "test_helper"

class GeoTermTest < ActiveSupport::TestCase
  def setup
    @geo_term = GeoTerm.new(
      term: "test term",
      parsed_response: { "results" => [] }
    )
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @geo_term.valid?
  end

  test "term should be present" do
    @geo_term.term = ""
    assert_not @geo_term.valid?
    assert_includes @geo_term.errors[:term], "can't be blank"
  end

  test "term should be unique" do
    @geo_term.save!
    duplicate_term = GeoTerm.new(
      term: @geo_term.term,
      parsed_response: { "results" => [] }
    )
    assert_not duplicate_term.valid?
    assert_includes duplicate_term.errors[:term], "has already been taken"
  end

  test "term should not exceed 255 characters" do
    @geo_term.term = "a" * 256
    assert_not @geo_term.valid?
    assert_includes @geo_term.errors[:term], "is too long (maximum is 255 characters)"
  end

  test "term should be valid with exactly 255 characters" do
    @geo_term.term = "a" * 255
    assert @geo_term.valid?
  end

  test "parsed_response should not be nil" do
    @geo_term.parsed_response = nil
    assert_not @geo_term.valid?
    assert_includes @geo_term.errors[:parsed_response], "is reserved"
  end

  # Normalization tests
  test "should normalize term to lowercase" do
    @geo_term.term = "  TEST TERM  "
    @geo_term.save!
    assert_equal "test term", @geo_term.term
  end

  test "should strip whitespace from term" do
    @geo_term.term = "  test term  "
    @geo_term.save!
    assert_equal "test term", @geo_term.term
  end

  # Class method tests
  test "normalize_term should normalize term correctly" do
    assert_equal "test term", GeoTerm.normalize_term("  TEST TERM  ")
  end

  test "normalize_term should return nil for blank input" do
    assert_nil GeoTerm.normalize_term(nil)
    assert_nil GeoTerm.normalize_term("")
  end
end
