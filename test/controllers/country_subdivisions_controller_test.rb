require "test_helper"

class CountrySubdivisionsControllerTest < ActionDispatch::IntegrationTest
  test "should return subdivisions for valid country" do
    get_subdivisions(country_id: countries(:canada).id)
    assert_response :success
    assert_match "Ontario", response.body
    assert_match "select", response.body
  end

  test "should return text input for invalid country_id" do
    get_subdivisions(country_id: 99999)
    assert_response :success
    assert_match "input", response.body
    assert_no_match "select", response.body
  end

  test "should return text input when country_id is missing" do
    get_subdivisions
    assert_response :success
    assert_match "input", response.body
  end

  test "should preserve region_value parameter" do
    get_subdivisions(country_id: countries(:canada).id, region_value: "Ontario")
    assert_response :success
    assert_match "selected", response.body
  end

  test "should invalidate cache when subdivision is created" do
    canada = countries(:canada)
    get_subdivisions(country_id: canada.id)
    assert_response :success
    assert_no_match "Quebec", response.body

    CountrySubdivision.create!(country: canada, name: "Quebec", code: "QC", subdivision_type: "Province")

    get_subdivisions(country_id: canada.id)
    assert_response :success
    assert_match "Quebec", response.body
  end

  test "should invalidate cache when subdivision is updated" do
    canada = countries(:canada)
    ontario = country_subdivisions(:ontario)
    get_subdivisions(country_id: canada.id)
    assert_response :success

    ontario.update!(name: "Ontario Updated")

    get_subdivisions(country_id: canada.id)
    assert_response :success
    assert_match "Ontario Updated", response.body
  end

  test "should invalidate cache when subdivision is destroyed" do
    canada = countries(:canada)
    get_subdivisions(country_id: canada.id)
    assert_response :success
    assert_match "Ontario", response.body

    country_subdivisions(:ontario).destroy!

    get_subdivisions(country_id: canada.id)
    assert_response :success
    assert_no_match "Ontario", response.body
  end

  private
    def get_subdivisions(params = {})
      get "/country_subdivisions", params:, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
end
