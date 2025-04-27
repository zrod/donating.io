require "test_helper"

class CountryTest < ActiveSupport::TestCase
  def setup
    @country = Country.new(name: "Test Country", iso_alpha3: "TST")
  end

  # Association tests
  test "should have many places" do
    assert_respond_to @country, :places
  end

  test "should nullify associated places when destroyed" do
    @country.save
    place = places(:donation_bin_published_one)
    place.update!(country: @country)

    assert_equal @country.id, place.country_id
    @country.destroy

    place.reload
    assert_nil place.country_id
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @country.valid?
  end

  test "name should be present" do
    @country.name = ""
    assert_not @country.valid?
    assert_includes @country.errors[:name], "can't be blank"
  end

  test "iso_alpha3 should be unique" do
    @country.save
    duplicate_country = @country.dup
    duplicate_country.name = "Another Country"
    assert_not duplicate_country.valid?
    assert_includes duplicate_country.errors[:iso_alpha3], "has already been taken"
  end

  # Database defaults tests
  test "should have default weight of 0" do
    @country.save
    @country.reload
    assert_equal 0, @country.weight
  end

  test "should have default active status of false" do
    @country.save
    @country.reload
    assert_equal false, @country.active
  end
end
