require "test_helper"

class PlacesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_place_url
    assert_response :success
  end

  test "should create place when authenticated" do
    user = users(:user_one)
    sign_in_as(user)

    assert_difference("Place.count") do
      post places_url, params: { place: {
        name: "Test Place",
        description: "Test description",
        address: "123 Test St",
        city: "Test City",
        lat: 45.0,
        lng: -75.0,
        pickup: false,
        used_ok: true,
        country_id: countries(:canada).id,
        category_ids: [categories(:clothing).id]
      } }
    end

    assert_redirected_to places_path
  end

  test "should handle duplicate place creation and show error message" do
    user = users(:user_one)
    sign_in_as(user)

    test_place = places(:published_bin_with_full_attributes_one)
    place_params = test_place.attributes.except("id", "created_at", "updated_at")

    assert_no_difference("Place.count") do
      post places_url, params: { place: place_params }
    end

    assert_response :unprocessable_content
  end
end
