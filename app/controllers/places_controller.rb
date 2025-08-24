class PlacesController < ApplicationController
  allow_unauthenticated_access only: %i[index new]
  rate_limit to: 10, within: 1.minute, only: :create, with: -> { redirect_to new_place_path, alert: I18n.t("controllers.places.create.too_many_requests") }

  def index
    @places = Place.all
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
      render :new, status: :unprocessable_entity
    end
  end

  private
    def filter_params
      params.permit(
        :cat,
        :charity,
        :near,
        :opening_hours,
        :page,
        :pickup,
        :radius,
        :used_ok,
        :bin_only,
        :tax_receipt
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
          day
          from_hour
          to_hour
          _destroy
        ]
      )
    end
end
