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
        categories_places_attributes: [{ category_id: categories(:clothing).id }]
      } }
    end

    assert_redirected_to root_path
  end

  test "should cache form data and redirect to login when unauthenticated" do
    place_params = {
      name: "Test Place",
      description: "Test description",
      address: "123 Test St",
      city: "Test City",
      lat: 45.0,
      lng: -75.0,
      pickup: false,
      used_ok: true,
      country_id: countries(:canada).id,
      categories_places_attributes: [{ category_id: categories(:clothing).id }]
    }

    post places_url, params: { place: place_params }

    assert_redirected_to new_session_path
    assert_equal "Please sign in or create an account to submit your place. Your form data has been saved and will be restored after authentication.", flash[:alert]
    assert_nil session[:cached_place_data]
    assert_equal new_place_path, session[:return_to_after_authenticating]
  end
end
