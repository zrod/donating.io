require "test_helper"

class CategoriesPlaceTest < ActiveSupport::TestCase
  def setup
    @place = places(:donation_bin_published_one)
    @category = categories(:books)
    @categories_place = CategoriesPlace.new(
      place: @place,
      category: @category
    )
  end

  # Association tests
  test "should belong to place" do
    assert_respond_to @categories_place, :place
  end

  test "should belong to category" do
    assert_respond_to @categories_place, :category
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @categories_place.valid?, @categories_place.errors.full_messages.to_sentence
  end

  test "should require place" do
    @categories_place.place = nil
    assert_not @categories_place.valid?
    assert_includes @categories_place.errors[:place], "can't be blank"
  end

  test "should require category" do
    @categories_place.category = nil
    assert_not @categories_place.valid?
    assert_includes @categories_place.errors[:category], "can't be blank"
  end

  test "should allow creation with valid attributes" do
    assert_difference "CategoriesPlace.count", 1 do
      CategoriesPlace.create!(
        place: places(:donation_bin_published_one),
        category: categories(:clothing)
      )
    end
  end
end
