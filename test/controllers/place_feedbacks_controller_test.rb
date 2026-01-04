require "test_helper"

class PlaceFeedbacksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @place = places(:published_bin_with_full_attributes_one)
    @user = users(:user_one)
  end

  test "should require authentication to create feedback" do
    post place_place_feedbacks_path(@place.slug), params: {
      place_feedback: {
        reason: "incorrect_address",
        details: "Test details"
      }
    }

    assert_redirected_to new_session_path
  end

  test "should create feedback with valid attributes" do
    sign_in_as(@user)

    assert_difference("PlaceFeedback.count") do
      post place_place_feedbacks_path(@place.slug), params: {
        place_feedback: {
          reason: "incorrect_address",
          details: "The address is incorrect"
        }
      }
    end

    assert_redirected_to place_path(@place)
    assert_equal I18n.t("controllers.place_feedbacks.create.success"), flash[:notice]

    feedback = PlaceFeedback.last
    assert_equal @place, feedback.place
    assert_equal @user, feedback.user
    assert_equal "incorrect_address", feedback.reason
    assert_equal "The address is incorrect", feedback.details
  end

  test "should create feedback with all valid reason types" do
    sign_in_as(@user)

    PlaceFeedback.reasons.keys.each do |reason|
      assert_difference("PlaceFeedback.count") do
        post place_place_feedbacks_path(@place.slug), params: {
          place_feedback: {
            reason:,
            details: "Test details for #{reason}"
          }
        }
      end

      assert_redirected_to place_path(@place)
      assert_equal I18n.t("controllers.place_feedbacks.create.success"), flash[:notice]
    end
  end

  test "should create feedback without details" do
    sign_in_as(@user)

    assert_difference("PlaceFeedback.count") do
      post place_place_feedbacks_path(@place.slug), params: {
        place_feedback: {
          reason: "closed"
        }
      }
    end

    assert_redirected_to place_path(@place)
    assert_equal I18n.t("controllers.place_feedbacks.create.success"), flash[:notice]

    feedback = PlaceFeedback.last
    assert_nil feedback.details
  end

  test "should not create feedback without reason" do
    sign_in_as(@user)

    assert_no_difference("PlaceFeedback.count") do
      post place_place_feedbacks_path(@place.slug), params: {
        place_feedback: {
          details: "Test details"
        }
      }
    end

    assert_redirected_to place_path(@place)
    assert flash[:alert].present?
    assert_includes flash[:alert], "can't be blank"
  end

  test "should redirect with error message when validation fails" do
    sign_in_as(@user)

    post place_place_feedbacks_path(@place.slug), params: {
      place_feedback: {
        reason: nil,
        details: "Test details"
      }
    }

    assert_redirected_to place_path(@place)
    assert flash[:alert].present?
  end

  test "should find place by slug" do
    sign_in_as(@user)

    assert_difference("PlaceFeedback.count") do
      post place_place_feedbacks_path(@place.slug), params: {
        place_feedback: {
          reason: "wrong_information",
          details: "Some information is wrong"
        }
      }
    end

    feedback = PlaceFeedback.last
    assert_equal @place, feedback.place
  end

  test "should return 404 when place slug is invalid" do
    sign_in_as(@user)

    post place_place_feedbacks_path("invalid-slug"), params: {
      place_feedback: {
        reason: "incorrect_address",
        details: "Test details"
      }
    }

    assert_response :not_found
  end

  test "should assign current user to feedback" do
    sign_in_as(@user)

    post place_place_feedbacks_path(@place.slug), params: {
      place_feedback: {
        reason: "no_longer_accepts_donations",
        details: "They stopped accepting donations"
      }
    }

    feedback = PlaceFeedback.last
    assert_equal @user, feedback.user
  end

  test "should handle multiple feedbacks from same user for same place" do
    sign_in_as(@user)

    assert_difference("PlaceFeedback.count", 2) do
      post place_place_feedbacks_path(@place.slug), params: {
        place_feedback: {
          reason: "incorrect_address",
          details: "First feedback"
        }
      }

      assert_redirected_to place_path(@place)

      post place_place_feedbacks_path(@place.slug), params: {
        place_feedback: {
          reason: "closed",
          details: "Second feedback"
        }
      }

      assert_redirected_to place_path(@place)
    end
  end
end
