require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  def setup
    @category = Category.new(name: "Test Category")
  end

  # Association tests
  test "should have many categories_places" do
    assert_respond_to @category, :categories_places
  end

  test "should have many places" do
    assert_respond_to @category, :places
  end

  test "should destroy associated categories_places when destroyed" do
    @category.save
    @category.categories_places.create!(place: Place.first)
    assert_difference "CategoriesPlace.count", -1 do
      @category.destroy
    end
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @category.valid?
  end

  test "name should be present" do
    @category.name = ""
    assert_not @category.valid?
    assert_includes @category.errors[:name], "can't be blank"
  end

  test "name should have minimum length of 4 characters" do
    @category.name = "Abc"
    assert_not @category.valid?
    assert_includes @category.errors[:name], "is too short (minimum is 4 characters)"
  end

  test "slug should be unique" do
    @category.save
    duplicate_category = @category.dup
    duplicate_category.name = "Test Category 2"
    duplicate_category.slug = @category.slug
    assert_not duplicate_category.valid?
    assert_includes duplicate_category.errors[:slug], "has already been taken"
  end

  # Callback tests
  test "should parameterize name to create slug before saving" do
    @category.name = "Test Category Name"
    @category.save
    assert_equal "test-category-name", @category.slug
  end

  test "should handle special characters in name when creating slug" do
    @category.name = "Test & Category! With? Special: Characters;"
    @category.save
    assert_equal "test-category-with-special-characters", @category.slug
  end
end
