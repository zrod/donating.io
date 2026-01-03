require "test_helper"

module Users
  class DestroyUserServiceTest < ActiveSupport::TestCase
    def setup
      @user = users(:user_one)
      @user_two = users(:user_two)
      @community_user = User.community_user
    end

    test "should destroy user" do
      user_id = @user.id
      service = DestroyUserService.new(user: @user, keep_contributions: false)

      assert_difference "User.count", -1 do
        service.call
      end

      refute User.exists?(user_id)
    end

    test "should destroy user with places when keep_contributions is false" do
      place = places(:published_bin_with_full_attributes_one)
      user_places_count = @user.places.count
      user_id = @user.id
      place_id = place.id

      service = DestroyUserService.new(user: @user, keep_contributions: false)

      assert_difference "User.count", -1 do
        assert_difference "Place.count", -user_places_count do
          service.call
        end
      end

      refute User.exists?(user_id)
      refute Place.exists?(place_id)
    end

    test "should transfer places to community user when keep_contributions is true" do
      place1 = places(:published_bin_with_full_attributes_one)
      place2 = places(:published_bin_toronto_one)
      user_id = @user.id

      service = DestroyUserService.new(user: @user, keep_contributions: true)

      assert_difference "User.count", -1 do
        assert_no_difference "Place.count" do
          service.call
        end
      end

      refute User.exists?(user_id)
      place1.reload
      place2.reload
      assert_equal @community_user.id, place1.user_id
      assert_equal @community_user.id, place2.user_id
    end

    test "should destroy user with keep_contributions true when user has no places" do
      user_id = @user_two.id

      service = DestroyUserService.new(user: @user_two, keep_contributions: true)

      assert_difference "User.count", -1 do
        service.call
      end

      refute User.exists?(user_id)
    end

    test "should transfer multiple places to community user" do
      place1 = places(:published_bin_with_full_attributes_one)
      place2 = places(:published_bin_toronto_one)

      service = DestroyUserService.new(user: @user, keep_contributions: true)

      service.call

      [place1, place2].each do |place|
        place.reload
        assert_equal @community_user.id, place.user_id
      end
    end

    test "should execute in a transaction" do
      place = places(:published_bin_with_full_attributes_one)

      # Stub destroy! to raise an error to test transaction rollback
      @user.stubs(:destroy!).raises(ActiveRecord::RecordInvalid.new(@user))

      service = DestroyUserService.new(user: @user, keep_contributions: true)

      assert_raises ActiveRecord::RecordInvalid do
        service.call
      end

      # Verify transaction rolled back - place should still belong to original user
      place.reload
      assert_equal @user.id, place.user_id
      assert User.exists?(@user.id)
    end

    test "should not transfer places when keep_contributions is false" do
      original_community_places_count = @community_user.places.count

      service = DestroyUserService.new(user: @user, keep_contributions: false)

      service.call

      # Community user should not have gained any places
      assert_equal original_community_places_count, @community_user.places.count
    end
  end
end
