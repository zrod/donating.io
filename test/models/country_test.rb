require "test_helper"

class CountryTest < ActiveSupport::TestCase
  def setup
    @country = Country.new(name: "Test Country", iso_alpha3: "TST")
  end

  # Association tests
  test "should have many places" do
    assert_respond_to @country, :places
  end

  test "should have many country_subdivisions" do
    assert_respond_to @country, :country_subdivisions
  end

  test "should destroy associated country_subdivisions when destroyed" do
    @country.save!
    @country.country_subdivisions.create!(name: "Test Province", code: "TP")

    assert_difference "CountrySubdivision.count", -1 do
      @country.destroy
    end
  end

  test "should prevent destruction when associated places exist" do
    @country.save
    place = places(:published_bin_with_full_attributes_one)
    place.update!(country: @country)

    assert_equal @country.id, place.country_id

    result = @country.destroy
    refute result

    assert @country.errors.any?
    assert_includes @country.errors.full_messages.join, "places"
    refute @country.destroyed?

    place.reload
    assert_equal @country.id, place.country_id
  end

  test "should allow destruction when no associated places exist" do
    @country.save

    # Should destroy successfully when no places exist
    result = @country.destroy
    assert result
    assert @country.destroyed?
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @country.valid?
  end

  test "name should be present" do
    @country.name = ""
    refute @country.valid?
    assert_includes @country.errors[:name], "can't be blank"
  end

  test "iso_alpha3 should be unique" do
    @country.save
    duplicate_country = @country.dup
    duplicate_country.name = "Another Country"
    refute duplicate_country.valid?
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

  # Scopes
  test "by_weight should return countries ordered by weight descending" do
    Country.update_all(weight: 0)

    canada = countries(:canada)
    brazil = countries(:brazil)

    brazil.update!(weight: 10, active: true)
    canada.update!(weight: 5, active: true)

    result = Country.by_weight

    assert_equal [ brazil.id, canada.id ], result[0..1].pluck(:id)
  end

  test "active should return active countries" do
    Country.update_all(active: false)

    assert_empty Country.active
  end
end
