require "test_helper"

class PlaceHourTest < ActiveSupport::TestCase
  def setup
    @place = places(:donation_bin_published_one)
    @place_hour = PlaceHour.new(
      place: @place,
      day_of_week: 2,
      from_hour: 900,
      to_hour: 1700
    )
  end

  # Association tests
  test "should belong to place" do
    assert_respond_to @place_hour, :place
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @place_hour.valid?, @place_hour.errors.full_messages.to_sentence
  end

  test "should require day_of_week" do
    @place_hour.day_of_week = nil
    assert_not @place_hour.valid?
    assert_includes @place_hour.errors[:day_of_week], "can't be blank"
  end

  test "day_of_week should be between 1 and 7" do
    @place_hour.day_of_week = 0
    assert_not @place_hour.valid?
    assert_includes @place_hour.errors[:day_of_week], "must be greater than 0"

    @place_hour.day_of_week = 8
    assert_not @place_hour.valid?
    assert_includes @place_hour.errors[:day_of_week], "must be less than 8"

    @place_hour.day_of_week = 1
    assert @place_hour.valid?

    @place_hour.day_of_week = 7
    assert @place_hour.valid?
  end

  test "should require from_hour" do
    @place_hour.from_hour = nil
    assert_not @place_hour.valid?
    assert_includes @place_hour.errors[:from_hour], "can't be blank"
  end

  test "from_hour should be numerical" do
    @place_hour.from_hour = "abc"
    assert_not @place_hour.valid?
  end

  test "from_hour should be between 0 and 2330" do
    @place_hour.from_hour = -1
    assert_not @place_hour.valid?

    @place_hour.from_hour = 2331
    assert_not @place_hour.valid?

    @place_hour.from_hour = 0
    assert @place_hour.valid?

    @place_hour.from_hour = 2330
    @place_hour.to_hour = 2400
    assert @place_hour.valid?
  end

  test "should require to_hour" do
    @place_hour.to_hour = nil
    assert_not @place_hour.valid?
    assert_includes @place_hour.errors[:to_hour], "can't be blank"
  end

  test "to_hour should be numerical" do
    @place_hour.to_hour = "abc"
    assert_not @place_hour.valid?
  end

  test "to_hour should be between 3000 and 2400" do
    @place_hour.to_hour = 29
    assert_not @place_hour.valid?

    @place_hour.to_hour = 2401
    assert_not @place_hour.valid?

    @place_hour.from_hour = 10
    @place_hour.to_hour = 30
    assert @place_hour.valid?

    @place_hour.to_hour = 2400
    assert @place_hour.valid?
  end

  test "from_hour should be less than to_hour" do
    @place_hour.from_hour = 1000
    @place_hour.to_hour = 900
    assert_not @place_hour.valid?
    assert_includes @place_hour.errors[:from_hour], I18n.t("activerecord.attributes.place_hour.from_hour_must_be_lower_than_to_hour")

    @place_hour.from_hour = 1000
    @place_hour.to_hour = 1000
    assert_not @place_hour.valid?

    @place_hour.from_hour = 900
    @place_hour.to_hour = 1000
    assert @place_hour.valid?
  end

  # Default scope test
  test "should order by day_of_week ascending" do
    PlaceHour.delete_all

    place_hour1 = PlaceHour.create!(place: @place, day_of_week: 3, from_hour: 900, to_hour: 1700)
    place_hour2 = PlaceHour.create!(place: @place, day_of_week: 1, from_hour: 900, to_hour: 1700)
    place_hour3 = PlaceHour.create!(place: @place, day_of_week: 5, from_hour: 900, to_hour: 1700)

    place_hours = PlaceHour.all
    assert_equal 3, place_hours.size
    assert_equal 1, place_hours.first.day_of_week
    assert_equal 3, place_hours.second.day_of_week
    assert_equal 5, place_hours.last.day_of_week
  end

  # Instance method tests
  test "key should return concatenated string of from_hour, to_hour, and day_of_week" do
    @place_hour.from_hour = 900
    @place_hour.to_hour = 1700
    @place_hour.day_of_week = 2

    expected_key = "9001700#{@place_hour.day_of_week}"
    assert_equal expected_key, @place_hour.key
  end
end
