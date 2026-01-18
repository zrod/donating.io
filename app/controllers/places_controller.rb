class PlacesController < ApplicationController
  include Pagination

  allow_unauthenticated_access only: %i[index show new]
  rate_limit to: 10, within: 1.minute, only: :create, with: -> { redirect_to new_place_path, alert: I18n.t("controllers.places.create.too_many_requests") }

  before_action :load_place_by_slug, only: %i[show edit update destroy]
  before_action :verify_ownership, only: %i[edit update destroy]

  def index
    @places, page_metadata = paginate(
      collection: filter_places_service.new(params: filter_params).call,
      filter_params:
    )

    @pages = page_metadata[:pages]
    @places_total = page_metadata[:total]

    respond_to do |format|
      format.html
      format.json
    end
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
    @place.errors.add(:base, t(".record_not_unique"))
    @categories = Category.by_name
    render :new, status: :unprocessable_content
  end

  def show; end

  def edit
    @categories = Category.by_name
  end

  def update
    if @place.update(place_params)
      redirect_to places_path, notice: t(".success")
    else
      @categories = Category.by_name
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @place.destroy
    redirect_to my_contributions_places_path, notice: I18n.t("controllers.places.destroy.success")
  end

  def bulk_delete
    place_ids = params[:place_ids] || []

    if place_ids.any?
      deleted_count = current_user.places.where(id: place_ids).destroy_all.count
      redirect_to my_contributions_places_path, notice: t("controllers.places.bulk_delete.success", count: deleted_count)
    else
      redirect_to my_contributions_places_path, alert: t(".nothing_selected")
    end
  end

  private
    def load_place_by_slug
      @place = Place.find_by!(slug: params[:slug])
    end

    def filter_params
      params.permit(
        *(filter_places_service::FILTERS - [:category_ids]),
        :lat,
        :lng,
        :radius,
        category_ids: [],
        opening_hours: [:start_time, :end_time, :day_of_week]
      )
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

    def verify_ownership
      redirect_to places_path, alert: t(".denied") unless current_user&.id == @place.user_id
    end
end
