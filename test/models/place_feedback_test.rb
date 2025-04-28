require "test_helper"

class PlaceFeedbackTest < ActiveSupport::TestCase
  def setup
    @place = places(:donation_bin_published_one)
    @user = users(:user_one)
    @place_feedback = PlaceFeedback.new(
      reason: :incorrect_address,
      place: @place,
      user: @user
    )
  end

  # Association tests
  test "should belong to place" do
    assert_respond_to @place_feedback, :place
  end

  test "should belong to user" do
    assert_respond_to @place_feedback, :user
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @place_feedback.valid?, @place_feedback.errors.full_messages.to_sentence
  end

  test "should require reason" do
    @place_feedback.reason = nil
    assert_not @place_feedback.valid?
    assert_includes @place_feedback.errors[:reason], "can't be blank"
  end

  # Enums raise ArgumentError for invalid values, not validation errors
  test "should raise error for invalid reason" do
    assert_raises(ArgumentError) do
      @place_feedback.reason = :invalid_reason
    end

    assert_raises(ArgumentError) do
      @place_feedback.reason = 99
    end
  end

  test "should accept all valid reasons" do
    PlaceFeedback.reasons.keys.each do |reason_key|
      @place_feedback.reason = reason_key
      assert @place_feedback.valid?, "#{reason_key} should be a valid reason"
    end
  end

  test "should have enum helper methods" do
    @place_feedback.closed!
    assert @place_feedback.closed?
    assert_equal "closed", @place_feedback.reason

    @place_feedback.reason = :other
    assert @place_feedback.other?
  end

  test "should have enum scopes" do
    # Delete any existing records to start fresh
    PlaceFeedback.destroy_all

    # Create and save instance with a specific reason
    feedback = PlaceFeedback.create!(reason: :closed, place: @place, user: @user)

    # Test the scope
    assert_includes PlaceFeedback.closed, feedback
    assert_equal 1, PlaceFeedback.closed.count
  end

  test "should require place" do
    @place_feedback.place = nil
    assert_not @place_feedback.valid?
    assert_includes @place_feedback.errors[:place], "must exist"
  end

  test "should require user" do
    @place_feedback.user = nil
    assert_not @place_feedback.valid?
    assert_includes @place_feedback.errors[:user], "must exist"
  end
end
