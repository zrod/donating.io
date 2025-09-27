class PlacesController < ApplicationController
  include Pagination

  allow_unauthenticated_access only: %i[index new]
  rate_limit to: 10, within: 1.minute, only: :create, with: -> { redirect_to new_place_path, alert: I18n.t("controllers.places.create.too_many_requests") }

  def index
    @places, page_metadata = paginate(
      collection: filter_places_service.new(params: filter_params).call,
      filter_params:
    )

    @pages = page_metadata[:pages]
    @places_total = page_metadata[:total]
  end

  def my_contributions
    @places, page_metadata = paginate(
      collection: filter_places_service.new(params: filter_params, relation: current_user.places).call,
      filter_params:
    )

    @pages = page_metadata[:pages]
    @places_total = page_metadata[:total]
    @selected_ids = params[:selected_ids]&.split(",") || []
  end

  def new
    @place = Place.new
    @place.place_hours.build
    @categories = Category.by_name
  end

  def create
    @place = Place.new(place_params)
    @place.user = current_user

    if @place.save
      redirect_to places_path, notice: I18n.t("controllers.places.create.success")
    else
      @categories = Category.by_name
      render :new, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique
    @place.errors.add(:base, "A place with this name and location already exists")
    @categories = Category.by_name
    render :new, status: :unprocessable_content
  end

  def edit
    @place = Place.find(params[:id])
    @categories = Category.by_name
    authorize_place_owner!
  end

  def update
    @place = Place.find(params[:id])
    authorize_place_owner!

    if @place.update(place_params)
      redirect_to places_path, notice: "Place updated successfully."
    else
      @categories = Category.by_name
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @place = Place.find(params[:id])
    authorize_place_owner!

    @place.destroy
    redirect_to user_places_path, notice: "Place deleted successfully."
  end

  def bulk_delete
    place_ids = params[:place_ids] || []
    if place_ids.any?
      deleted_count = current_user.places.where(id: place_ids).destroy_all.count
      redirect_to my_contributions_places_path, notice: "#{deleted_count} place#{'s' if deleted_count != 1} deleted successfully."
    else
      redirect_to my_contributions_places_path, alert: "No places selected for deletion."
    end
  end

  private
    def filter_params
      params.permit(filter_places_service::FILTERS)
    end

    def place_params
      params.require(:place).permit(
        :name,
        :description,
        :email,
        :address,
        :postal_code,
        :city,
        :region,
        :phone,
        :charity_support,
        :location_instructions,
        :lat,
        :lng,
        :osm_id,
        :pickup,
        :url,
        :used_ok,
        :is_bin,
        :tax_receipt,
        :country_id,
        category_ids: [],
        place_hours_attributes: %i[
          id
          day_of_week
          from_hour
          to_hour
          _destroy
        ]
      )
    end

    def filter_places_service
      Places::FilterPlacesService
    end

    def authorize_place_owner!
      redirect_to places_path, alert: "You can only edit your own places." unless current_user&.id == @place.user_id
    end
end
