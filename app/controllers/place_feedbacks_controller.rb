class PlaceFeedbacksController < ApplicationController
  before_action :load_place_by_slug

  def create
    @place_feedback = @place.place_feedbacks.build(place_feedback_params)
    @place_feedback.user = current_user

    if @place_feedback.save
      flash[:notice] = I18n.t("controllers.place_feedbacks.create.success")
      redirect_to place_path(@place)
    else
      flash[:alert] = @place_feedback.errors.full_messages.join(", ")
      redirect_to place_path(@place)
    end
  end

  private
    def load_place_by_slug
      @place = Place.find_by!(slug: params[:place_slug])
    end

    def place_feedback_params
      params.require(:place_feedback).permit(:reason, :details)
    end
end
