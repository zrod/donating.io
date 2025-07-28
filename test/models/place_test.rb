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
  test "belongs to user" do
    assert_respond_to @place, :user
    assert_equal users(:user_one), @place.user
  end

  test "belongs to country" do
    assert_respond_to @place, :country
    assert_equal countries(:canada), @place.country
  end

  test "has many categories_places" do
    place = places(:donation_bin_published_one)
    assert_respond_to place, :categories_places
    assert place.categories_places.any?
  end

  test "has many categories through categories_places" do
    place = places(:donation_bin_published_one)
    assert_respond_to place, :categories
    assert_includes place.categories, categories(:books)
  end

  test "has many place_hours" do
    assert_respond_to @place, :place_hours
  end

  test "has many place_feedbacks" do
    assert_respond_to @place, :place_feedbacks
  end

  test "destroys associated records when destroyed" do
    @place.save!
    @place.place_hours.create!(day_of_week: 1, from_hour: 900, to_hour: 1700)
    @place.place_feedbacks.create!(reason: "other", user: users(:user_two))

    assert_difference [ "CategoriesPlace.count", "PlaceHour.count", "PlaceFeedback.count" ], -1 do
      @place.destroy
    end
  end

  # Validation tests
  test "valid with all required attributes" do
    assert @place.valid?, @place.errors.full_messages.join(", ")
  end

  test "invalid without name" do
    @place.name = nil
    assert_not @place.valid?
    assert_includes @place.errors[:name], "can't be blank"
  end

  test "invalid with short name" do
    @place.name = "A" * (Place::NAME_MIN_LENGTH - 1)
    assert_not @place.valid?
    assert_includes @place.errors[:name], "is too short (minimum is #{Place::NAME_MIN_LENGTH} characters)"
  end

  test "invalid without categories" do
    @place.categories_places.clear
    assert_not @place.valid?
    assert_includes @place.errors[:categories_places], "can't be blank"
  end

  test "invalid without description" do
    @place.description = ""
    assert_not @place.valid?
    assert_includes @place.errors[:description], "can't be blank"
  end

  test "validates email format" do
    # Invalid email
    @place.email = "invalid-email"
    assert_not @place.valid?
    assert_includes @place.errors[:email], "is invalid"

    # Valid email
    @place.email = "valid@example.com"
    assert @place.valid?

    # Blank email is allowed
    @place.email = ""
    assert @place.valid?
  end

  test "invalid without address" do
    @place.address = nil
    assert_not @place.valid?
    assert_includes @place.errors[:address], "can't be blank"
  end

  test "invalid with short address" do
    @place.address = "A" * (Place::ADDRESS_MIN_LENGTH - 1)
    assert_not @place.valid?
    assert_includes @place.errors[:address], "is too short (minimum is #{Place::ADDRESS_MIN_LENGTH} characters)"
  end

  test "invalid with long postal code" do
    @place.postal_code = "A" * (Place::POSTAL_CODE_MAX_LENGTH + 1)
    assert_not @place.valid?
    assert_includes @place.errors[:postal_code], "is too long (maximum is #{Place::POSTAL_CODE_MAX_LENGTH} characters)"
  end

  test "invalid without city" do
    @place.city = ""
    assert_not @place.valid?
    assert_includes @place.errors[:city], "can't be blank"
  end

  test "invalid with short city" do
    @place.city = "A" * (Place::CITY_MIN_LENGTH - 1)
    assert_not @place.valid?
    assert_includes @place.errors[:city], "is too short (minimum is #{Place::CITY_MIN_LENGTH} characters)"
  end

  test "invalid without coordinates" do
    @place.lat = nil
    assert_not @place.valid?
    assert_includes @place.errors[:lat], "can't be blank"

    @place.lat = 45.123456
    @place.lng = nil
    assert_not @place.valid?
    assert_includes @place.errors[:lng], "can't be blank"
  end

  test "validates boolean fields" do
    @place.pickup = nil
    assert_not @place.valid?
    assert_includes @place.errors[:pickup], "is not included in the list"

    @place.pickup = false
    @place.used_ok = nil
    assert_not @place.valid?
    assert_includes @place.errors[:used_ok], "is not included in the list"
  end

  # Status and constants tests
  test "has correct status constants" do
    expected_statuses = { pending: 0, published: 1, removed: 2 }
    assert_equal expected_statuses, Place::STATUSES
  end

  test "published scope returns only published places" do
    published_places = Place.published
    assert_includes published_places, places(:donation_bin_published_one)

    published_places.each do |place|
      assert_equal Place::STATUSES[:published], place.status
    end
  end

  # Callback tests
  test "sets status to pending on create" do
    @place.save!
    assert_equal Place::STATUSES[:pending], @place.status
  end

  test "generates slug from name and coordinates on save" do
    @place.save!
    expected_slug = "test-place45-123456-75-654321"
    assert_equal expected_slug, @place.slug
  end

  test "updates slug when name or coordinates change" do
    @place.save!
    original_slug = @place.slug

    @place.update!(name: "New Name", lat: 50.0)
    assert_not_equal original_slug, @place.slug
    assert_includes @place.slug, "new-name50-0"
  end

  # Instance method tests
  test "full_address returns complete formatted address" do
    place = places(:donation_bin_published_one)
    expected = "123 front street, Toronto, Ontario, M1M 1A1, Canada"
    assert_equal expected, place.full_address
  end

  test "full_address handles missing region and postal_code" do
    @place.region = nil
    @place.postal_code = nil
    @place.save!

    expected = "123 Test Street, Test City, Canada"
    assert_equal expected, @place.full_address
  end

  test "geo_location returns coordinates as string" do
    expected = "45.123456,-75.654321"
    assert_equal expected, @place.geo_location
  end

  test "has_charity_support checks for charity_support presence" do
    # With charity support
    place = places(:donation_bin_published_one)
    assert place.has_charity_support

    # Without charity support
    @place.charity_support = nil
    assert_not @place.has_charity_support

    @place.charity_support = ""
    assert_not @place.has_charity_support

    @place.charity_support = "Some support info"
    assert @place.has_charity_support
  end

  # Nested attributes tests
  test "accepts nested attributes for categories_places" do
    place_attrs = {
      name: "Test Place",
      description: "Test Description",
      address: "123 Test Street",
      city: "Test City",
      lat: 45.0,
      lng: -75.0,
      pickup: false,
      used_ok: true,
      country_id: countries(:canada).id,
      user_id: users(:user_one).id,
      categories_places_attributes: [
        { category_id: categories(:books).id },
        { category_id: categories(:clothing).id }
      ]
    }

    place = Place.new(place_attrs)
    assert place.valid?
    assert_equal 2, place.categories_places.size
  end

  test "accepts nested attributes for place_hours" do
    place_attrs = {
      name: "Test Place",
      description: "Test Description",
      address: "123 Test Street",
      city: "Test City",
      lat: 45.0,
      lng: -75.0,
      pickup: false,
      used_ok: true,
      country_id: countries(:canada).id,
      user_id: users(:user_one).id,
      categories_places_attributes: [{ category_id: categories(:books).id }],
      place_hours_attributes: [
        { day_of_week: 1, from_hour: 900, to_hour: 1700 },
        { day_of_week: 2, from_hour: 1000, to_hour: 1800 }
      ]
    }

    place = Place.new(place_attrs)
    assert place.valid?
    assert_equal 2, place.place_hours.size
  end
end
