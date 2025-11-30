require "test_helper"

class CountrySubdivisionTest < ActiveSupport::TestCase
  def setup
    @country = countries(:canada)
    @subdivision = CountrySubdivision.new(
      country: @country,
      name: "Test Province",
      code: "TP"
    )
  end

  test "should belong to country" do
    assert_respond_to @subdivision, :country
  end

  test "should require a country" do
    @subdivision.country = nil
    refute @subdivision.valid?
    assert_includes @subdivision.errors[:country], "must exist"
  end

  test "should be valid with valid attributes" do
    assert @subdivision.valid?
  end

  test "name should be present" do
    @subdivision.name = ""
    refute @subdivision.valid?
    assert_includes @subdivision.errors[:name], "can't be blank"
  end

  test "name should not be nil" do
    @subdivision.name = nil
    refute @subdivision.valid?
    assert_includes @subdivision.errors[:name], "can't be blank"
  end

  test "code should be present" do
    @subdivision.code = ""
    refute @subdivision.valid?
    assert_includes @subdivision.errors[:code], "can't be blank"
  end

  test "code should not be nil" do
    @subdivision.code = nil
    refute @subdivision.valid?
    assert_includes @subdivision.errors[:code], "can't be blank"
  end

  test "code should be unique within country" do
    @subdivision.save!
    duplicate = CountrySubdivision.new(
      country: @country,
      name: "Another Province",
      code: "TP"
    )
    refute duplicate.valid?
    assert_includes duplicate.errors[:code], "has already been taken"
  end

  test "code can be duplicated across different countries" do
    @subdivision.save!
    other_country = countries(:brazil)
    other_subdivision = CountrySubdivision.new(
      country: other_country,
      name: "Test State",
      code: "TP"
    )
    assert other_subdivision.valid?
  end

  test "subdivision_type can be nil" do
    @subdivision.subdivision_type = nil
    assert @subdivision.valid?
  end

  test "subdivision_type can be set" do
    @subdivision.subdivision_type = "Province"
    assert @subdivision.valid?
    @subdivision.save!
    assert_equal "Province", @subdivision.reload.subdivision_type
  end
end
