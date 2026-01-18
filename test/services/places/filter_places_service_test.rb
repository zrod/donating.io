require "test_helper"

module Places
  class FilterPlacesServiceTest < ActiveSupport::TestCase
    test "should initialize with default relation" do
      service = FilterPlacesService.new(params: {})
      assert_equal Place.published.to_sql, service.relation.to_sql
    end

    test "should raise ArgumentError for invalid relation" do
      assert_raises ArgumentError do
        FilterPlacesService.new(params: {}, relation: Category.all)
      end

      assert_raises ArgumentError do
        FilterPlacesService.new(params: {}, relation: "not a relation")
      end
    end

    test "should return original relation if params are empty" do
      service = FilterPlacesService.new(params: {})
      assert_equal Place.published.to_sql, service.call.to_sql
    end

    test "should handle page parameter" do
      service = FilterPlacesService.new(params: {}, page: 2)
      assert_equal 2, service.page

      service = FilterPlacesService.new(params: {}, page: "3")
      assert_equal 3, service.page

      service = FilterPlacesService.new(params: {}, page: 0)
      assert_equal 1, service.page

      service = FilterPlacesService.new(params: {}, page: -1)
      assert_equal 1, service.page

      service = FilterPlacesService.new(params: {}, page: nil)
      assert_equal 1, service.page
    end

    test "should filter by pickup" do
      true_place, false_place = places_for_boolean_filter(:pickup)

      results = FilterPlacesService.new(params: { pickup: "true" }).call

      assert_includes results, true_place
      assert_not_includes results, false_place
    end

    test "should filter by used_ok" do
      true_place, false_place = places_for_boolean_filter(:used_ok)

      results = FilterPlacesService.new(params: { used_ok: "true" }).call

      assert_includes results, true_place
      assert_not_includes results, false_place
    end

    test "should filter by is_bin" do
      true_place, false_place = places_for_boolean_filter(:is_bin)

      results = FilterPlacesService.new(params: { is_bin: "true" }).call

      assert_includes results, true_place
      assert_not_includes results, false_place
    end

    test "should filter by tax_receipt" do
      true_place, false_place = places_for_boolean_filter(:tax_receipt)

      results = FilterPlacesService.new(params: { tax_receipt: "true" }).call

      assert_includes results, true_place
      assert_not_includes results, false_place
    end

    test "should filter by category_ids" do
      place_with_cat1 = places(:published_bin_with_full_attributes_one)

      category1 = place_with_cat1.categories.first
      category2 = Category.where.not(id: category1.id).first

      place_with_cat2 = Place.create!(
        name: "Place with cat 2",
        address: "789 Sub St",
        city: "Toronto",
        lat: 43.66,
        lng: -79.35,
        description: "A place with category 2",
        pickup: false,
        used_ok: true,
        country: countries(:canada),
        user: users(:user_one),
        categories: [category2]
      )
      place_with_cat2.update!(status: 1)

      results = FilterPlacesService.new(params: { category_ids: [category1.id] }).call

      assert_includes results, place_with_cat1
      assert_not_includes results, place_with_cat2

      results = FilterPlacesService.new(params: { category_ids: [category1.id, category2.id] }).call
      assert_includes results, place_with_cat1
      assert_includes results, place_with_cat2
    end

    test "should filter by charity_support when true" do
      charity_place = places(:published_bin_with_full_attributes_one)
      no_charity_place = Place.create!(
        name: "No Charity Place",
        charity_support: nil,
        address: "222 Charity Rd",
        city: "Toronto",
        lat: 43.67,
        lng: -79.36,
        description: "A place without charity support",
        pickup: false,
        used_ok: true,
        country: countries(:canada),
        user: users(:user_one),
        categories: [categories(:books)]
      )
      no_charity_place.update!(status: 1)

      results = FilterPlacesService.new(params: { charity_support: "true" }).call

      assert_includes results, charity_place
      assert_not_includes results, no_charity_place
    end

    test "should filter by charity_support when false" do
      charity_place = places(:published_bin_with_full_attributes_one)
      empty_charity_place = Place.create!(
        name: "Empty Charity Place",
        charity_support: "",
        address: "222 Charity Rd",
        city: "Toronto",
        lat: 43.67,
        lng: -79.36,
        description: "A place with empty charity support",
        pickup: false,
        used_ok: true,
        country: countries(:canada),
        user: users(:user_one),
        categories: [categories(:books)]
      )
      empty_charity_place.update!(status: 1)

      nil_charity_place = Place.create!(
        name: "Nil Charity Place",
        charity_support: nil,
        address: "223 Charity Rd",
        city: "Toronto",
        lat: 43.68,
        lng: -79.37,
        description: "A place with nil charity support",
        pickup: false,
        used_ok: true,
        country: countries(:canada),
        user: users(:user_one),
        categories: [categories(:books)]
      )
      nil_charity_place.update!(status: 1)

      results = FilterPlacesService.new(params: { charity_support: "false" }).call

      assert_not_includes results, charity_place
      assert_includes results, empty_charity_place
      assert_includes results, nil_charity_place
    end

    test "should handle various boolean-like values for charity_support" do
      charity_place = places(:published_bin_with_full_attributes_one)
      no_charity_place = Place.create!(
        name: "No Charity Place",
        charity_support: nil,
        address: "222 Charity Rd",
        city: "Toronto",
        lat: 43.67,
        lng: -79.36,
        description: "A place without charity support",
        pickup: false,
        used_ok: true,
        country: countries(:canada),
        user: users(:user_one),
        categories: [categories(:books)]
      )
      no_charity_place.update!(status: 1)

      results = FilterPlacesService.new(params: { charity_support: "1" }).call
      assert_includes results, charity_place
      assert_not_includes results, no_charity_place

      results = FilterPlacesService.new(params: { charity_support: "0" }).call
      assert_not_includes results, charity_place
      assert_includes results, no_charity_place

      results = FilterPlacesService.new(params: { charity_support: true }).call
      assert_includes results, charity_place
      assert_not_includes results, no_charity_place

      results = FilterPlacesService.new(params: { charity_support: false }).call
      assert_not_includes results, charity_place
      assert_includes results, no_charity_place
    end

    test "should filter by opening_hours" do
      open_place = Place.create!(
        name: "Open Place",
        address: "333 Open St",
        city: "Toronto",
        lat: 43.68,
        lng: -79.37,
        description: "A place that is open during specified hours",
        pickup: false,
        used_ok: true,
        country: countries(:canada),
        user: users(:user_one),
        categories: [categories(:books)]
      )
      open_place.update!(status: 1)
      open_place.place_hours.create!(day_of_week: 1, from_hour: 900, to_hour: 1700)

      closed_place = Place.create!(
        name: "Closed Place",
        address: "444 Closed St",
        city: "Toronto",
        lat: 43.69,
        lng: -79.38,
        description: "A place that is closed during specified hours",
        pickup: false,
        used_ok: true,
        country: countries(:canada),
        user: users(:user_one),
        categories: [categories(:books)]
      )
      closed_place.update!(status: 1)
      closed_place.place_hours.create!(day_of_week: 1, from_hour: 1800, to_hour: 2000)

      params = { opening_hours: { day_of_week: "1", start_time: "1000", end_time: "1600" } }
      results = FilterPlacesService.new(params:).call

      assert_includes results, open_place
      assert_not_includes results, closed_place
    end

    test "should handle nil opening_hours gracefully" do
      place = places(:published_bin_with_full_attributes_one)

      params = { opening_hours: nil }
      results = FilterPlacesService.new(params:).call

      assert_respond_to results, :each
      assert_includes results, place
    end

    test "should handle missing opening_hours key gracefully" do
      place = places(:published_bin_with_full_attributes_one)

      params = {}
      results = FilterPlacesService.new(params:).call

      assert_respond_to results, :each
      assert_includes results, place
    end

    test "should handle near_me filter with valid coordinates" do
      params = { near_me: "true", lat: "40.7128", lng: "-74.0060", radius: "10" }
      service = FilterPlacesService.new(params:)

      assert_nothing_raised do
        service.call.to_a
      end
    end

    test "should handle near_me filter with default radius" do
      params = { near_me: "true", lat: "40.7128", lng: "-74.0060" }
      service = FilterPlacesService.new(params:)

      assert_nothing_raised do
        service.call.to_a
      end
    end

    test "should handle near_me filter with missing coordinates" do
      # Test with missing lat
      service1 = FilterPlacesService.new(params: { near_me: "true", lng: "-74.0060" })
      result1 = service1.call.to_a

      # Test with missing lng
      service2 = FilterPlacesService.new(params: { near_me: "true", lat: "40.7128" })
      result2 = service2.call.to_a

      assert_respond_to result1, :each
      assert_respond_to result2, :each
    end

    test "should filter by coordinates when lat and lng are present but near_me is blank" do
      params = { lat: "40.7128", lng: "-74.0060", radius: "10" }
      service = FilterPlacesService.new(params:)

      assert_nothing_raised do
        service.call.to_a
      end
    end

    test "should filter by coordinates with default radius when lat and lng are present but near_me is blank" do
      params = { lat: "40.7128", lng: "-74.0060" }
      service = FilterPlacesService.new(params:)

      assert_nothing_raised do
        service.call.to_a
      end
    end

    test "should not filter by coordinates when near_me is present" do
      params = { near_me: "true", lat: "40.7128", lng: "-74.0060" }
      service = FilterPlacesService.new(params:)

      assert_nothing_raised do
        service.call.to_a
      end
    end

    test "should not error when combining geo + category_ids + opening_hours (forces distance ordering)" do
      category = categories(:books)
      params = {
        tax_receipt: "false",
        lat: "43.6531080645697",
        lng: "-79.355078026259",
        radius: "40",
        category_ids: [category.id.to_s],
        opening_hours: { start_time: "1400", end_time: "1900", day_of_week: "1" }
      }

      assert_nothing_raised do
        FilterPlacesService.new(params:).call.to_a
      end
    end

    test "should apply multiple filters together" do
      category = categories(:books)
      pickup_and_cat_place = Place.create!(
        name: "Pickup and Category Place",
        pickup: true,
        used_ok: true,
        address: "555 Combo St",
        city: "Toronto",
        lat: 43.70,
        lng: -79.39,
        description: "A place with pickup and specific category",
        country: countries(:canada),
        user: users(:user_one),
        categories: [category]
      )
      pickup_and_cat_place.update!(status: 1)

      pickup_only_place = Place.create!(
        name: "Pickup Only Place",
        pickup: true,
        used_ok: true,
        address: "666 Pickup St",
        city: "Toronto",
        lat: 43.71,
        lng: -79.40,
        description: "A place that only offers pickup",
        country: countries(:canada),
        user: users(:user_one),
        categories: [categories(:toys)]
      )
      pickup_only_place.update!(status: 1)

      params = { pickup: "true", category_ids: [category.id] }
      service = FilterPlacesService.new(params:)
      results = service.call

      assert_includes results, pickup_and_cat_place
      assert_not_includes results, pickup_only_place
    end

    test "should ignore blank and string category_ids like controller params" do
      place_with_cat1 = places(:published_bin_with_full_attributes_one)
      category1 = place_with_cat1.categories.first
      category2 = Category.where.not(id: category1.id).first

      place_with_cat2 = Place.create!(
        name: "Place with cat 2 (string params)",
        address: "789 Sub St",
        city: "Toronto",
        lat: 43.661,
        lng: -79.351,
        description: "A place with category 2",
        pickup: false,
        used_ok: true,
        country: countries(:canada),
        user: users(:user_one),
        categories: [category2]
      )
      place_with_cat2.update!(status: 1)

      results = FilterPlacesService.new(params: { category_ids: ["", "0", category1.id.to_s] }).call
      assert_includes results, place_with_cat1
      assert_not_includes results, place_with_cat2

      results = FilterPlacesService.new(params: { category_ids: ["", category1.id.to_s, category2.id.to_s] }).call
      assert_includes results, place_with_cat1
      assert_includes results, place_with_cat2
    end

    test "should handle partial filter params gracefully" do
      place = places(:published_bin_with_full_attributes_one)
      place.update!(pickup: true, used_ok: true)

      results = FilterPlacesService.new(params: { pickup: "true" }).call
      assert_respond_to results, :each
      assert_includes results, place

      results = FilterPlacesService.new(params: {}).call
      assert_respond_to results, :each
      assert_includes results, place
    end

    test "should sort by default updated_at DESC when no sort params provided" do
      old_place, new_place = setup_places_with_different_timestamps

      # Use a non-empty param to trigger sorting logic, but no sort-specific params
      results = FilterPlacesService.new(params: { pickup: "false" }).call

      assert_equal new_place.id, results.first.id
      assert_equal old_place.id, results.second.id
    end

    test "should sort by updated_at ASC when order is ASC" do
      old_place, new_place = setup_places_with_different_timestamps

      results = FilterPlacesService.new(params: { order: "asc" }).call

      assert_equal old_place.id, results.first.id
      assert_equal new_place.id, results.second.id
    end

    test "should sort by name when sort_by is name" do
      place_a, place_z = setup_places_with_names("A Place", "Z Place")

      results = FilterPlacesService.new(params: { sort_by: "name" }).call

      assert_equal place_z.id, results.first.id
      assert_equal place_a.id, results.second.id
    end

    test "should sort by name ASC when both sort_by and order are specified" do
      place_a, place_z = setup_places_with_names("A Place", "Z Place")

      results = FilterPlacesService.new(params: { sort_by: "name", order: "asc" }).call

      assert_equal place_a.id, results.first.id
      assert_equal place_z.id, results.second.id
    end

    test "should fallback to default sorting for invalid sort_by" do
      old_place, new_place = setup_places_with_different_timestamps

      results = FilterPlacesService.new(params: { sort_by: "invalid_column", pickup: "false" }).call

      assert_equal new_place.id, results.first.id
      assert_equal old_place.id, results.second.id
    end

    test "should fallback to default order for invalid order" do
      old_place, new_place = setup_places_with_different_timestamps

      results = FilterPlacesService.new(params: { order: "INVALID", pickup: "false" }).call

      assert_equal new_place.id, results.first.id
      assert_equal old_place.id, results.second.id
    end

    test "should handle case insensitive order parameter" do
      old_place, new_place = setup_places_with_different_timestamps

      results = FilterPlacesService.new(params: { order: "Asc" }).call

      assert_equal old_place.id, results.first.id
      assert_equal new_place.id, results.second.id
    end

    test "should filter by keyword searching name, address, and city" do
      matching_place = places(:published_bin_with_full_attributes_one)
      non_matching_place = places(:published_bin_toronto_one)

      results = FilterPlacesService.new(params: { keyword: "Donation" }).call
      assert_includes results, matching_place
      assert_not_includes results, non_matching_place

      results = FilterPlacesService.new(params: { keyword: matching_place.address.split.first }).call
      assert_includes results, matching_place
      assert_not_includes results, non_matching_place

      results = FilterPlacesService.new(params: { keyword: matching_place.city }).call
      assert_includes results, matching_place
      assert_includes results, non_matching_place
    end

    test "should handle case insensitive keyword search" do
      matching_place = places(:published_bin_with_full_attributes_one)
      name_word = matching_place.name.split.first

      results = FilterPlacesService.new(params: { keyword: name_word.upcase }).call
      assert_includes results, matching_place

      results = FilterPlacesService.new(params: { keyword: name_word.downcase }).call
      assert_includes results, matching_place

      results = FilterPlacesService.new(params: { keyword: name_word.swapcase }).call
      assert_includes results, matching_place
    end

    private
      def places_for_boolean_filter(attribute)
        true_place = places(:published_bin_with_full_attributes_one)
        true_place.update!(attribute => true)

        false_place = true_place.dup
        false_place.assign_attributes(
          name: "Test False Place",
          lat: true_place.lat + 0.01,
          attribute => false
        )
        false_place.categories << categories(:books)
        false_place.save!

        [true_place, false_place]
      end

      def setup_places_with_different_timestamps
        old_place = places(:published_bin_toronto_one)
        old_place.update!(updated_at: 2.days.ago)

        new_place = places(:published_bin_with_full_attributes_one)
        new_place.update!(updated_at: 1.day.ago)

        [old_place, new_place]
      end

      def setup_places_with_names(name_a, name_z)
        place_a = places(:published_bin_with_full_attributes_one)
        place_a.update!(name: name_a)

        place_z = places(:published_bin_toronto_one)
        place_z.update!(name: name_z)

        [place_a, place_z]
      end
  end
end
