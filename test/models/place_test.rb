require "test_helper"

class PlaceTest < ActiveSupport::TestCase
  def setup
    @place = Place.new(
      name: "Test Place",
      description: "Test Description",
      address: "123 Test Street",
      city: "Test City",
      lat: 45.123456,
      lng: -75.654321,
      postal_code: "A1B 2C3",
      pickup: false,
      used_ok: true,
      country: countries(:canada),
      user: users(:user_one)
    )
    @place.categories_places.build(category: categories(:books))
  end

  # Association tests
  test "should belong to user" do
    assert_respond_to @place, :user
  end

  test "should belong to country" do
    assert_respond_to @place, :country
  end

  test "should have many categories_places" do
    assert_respond_to @place, :categories_places
  end

  test "should have many categories through categories_places" do
    assert_respond_to @place, :categories
  end

  test "should have many place_hours" do
    assert_respond_to @place, :place_hours
  end

  test "may have many place_feedbacks" do
    assert_respond_to @place, :place_feedbacks
  end

  test "should destroy associated categories_places when destroyed" do
    @place.save
    assert_difference "CategoriesPlace.count", -1 do
      @place.destroy
    end
  end

  test "should destroy associated place_hours when destroyed" do
    @place.save
    @place.place_hours.create!(day_of_week: 1, from_hour: 900, to_hour: 1700)
    assert_difference "PlaceHour.count", -1 do
      @place.destroy
    end
  end

  test "should destroy associated place_feedbacks when destroyed" do
    @place.save
    @place.place_feedbacks.create!(reason: "other", user: users(:user_one))
    assert_difference "PlaceFeedback.count", -1 do
      @place.destroy
    end
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @place.valid?, @place.errors.full_messages.to_sentence
  end

  test "should require name" do
    @place.name = ""
    assert_not @place.valid?
    assert_includes @place.errors[:name], "can't be blank"
  end

  test "should require minimum name length" do
    @place.name = "ABC"
    assert_not @place.valid?
    assert_includes @place.errors[:name], "is too short (minimum is 4 characters)"
  end

  test "should require at least one category" do
    @place.categories_places.clear
    assert_not @place.valid?
    assert_includes @place.errors[:categories_places], "can't be blank"
  end

  test "should require description" do
    @place.description = ""
    assert_not @place.valid?
    assert_includes @place.errors[:description], "can't be blank"
  end

  test "should require valid email if provided" do
    @place.email = "invalid-email"
    assert_not @place.valid?
    assert_includes @place.errors[:email], "is invalid"

    @place.email = "valid@example.com"
    @place.valid?
    assert_empty @place.errors[:email]

    @place.email = ""
    @place.valid?
    assert_empty @place.errors[:email]
  end

  test "should require address" do
    @place.address = ""
    assert_not @place.valid?
    assert_includes @place.errors[:address], "can't be blank"
  end

  test "should require minimum address length" do
    @place.address = "12345"
    assert_not @place.valid?
    assert_includes @place.errors[:address], "is too short (minimum is 6 characters)"
  end

  test "should limit postal_code length" do
    @place.postal_code = "A" * 13
    assert_not @place.valid?
    assert_includes @place.errors[:postal_code], "is too long (maximum is 12 characters)"
  end

  test "should require city" do
    @place.city = ""
    assert_not @place.valid?
    assert_includes @place.errors[:city], "can't be blank"
  end

  test "should require minimum city length" do
    @place.city = "AB"
    assert_not @place.valid?
    assert_includes @place.errors[:city], "is too short (minimum is 3 characters)"
  end

  test "should require latitude" do
    @place.lat = nil
    assert_not @place.valid?
    assert_includes @place.errors[:lat], "can't be blank"
  end

  test "should require longitude" do
    @place.lng = nil
    assert_not @place.valid?
    assert_includes @place.errors[:lng], "can't be blank"
  end

  test "should require pickup to be boolean" do
    @place.pickup = nil
    assert_not @place.valid?
    assert_includes @place.errors[:pickup], "is not included in the list"
  end

  test "should require used_ok to be boolean" do
    @place.used_ok = nil
    assert_not @place.valid?
    assert_includes @place.errors[:used_ok], "is not included in the list"
  end

  # Scope tests
  test "published scope should return only published places" do
    published_places = Place.published
    assert_includes published_places, places(:donation_bin_published_one)
    assert_equal Place::STATUSES[:published], published_places.first.status
  end

  # Callback tests
  test "should set status to pending before create" do
    @place.save
    assert_equal Place::STATUSES[:pending], @place.status
  end

  test "should parameterize name with coordinates for slug before save" do
    @place.save
    expected_slug = "test-place45-123456-75-654321"
    assert_equal expected_slug, @place.slug
  end

  # Instance method tests
  test "full_address should return complete address with country" do
    @place.save
    expected_address = "123 Test Street, Test City, A1B 2C3, Canada"
    assert_equal expected_address, @place.full_address
  end

  test "geo_location should return lat,lng format" do
    expected_location = "45.123456,-75.654321"
    assert_equal expected_location, @place.geo_location
  end

  test "has_charity_support should return true when charity_support is present" do
    @place.charity_support = nil
    assert_not @place.has_charity_support

    @place.charity_support = "Support information"
    assert @place.has_charity_support
  end
end
