class PlacesController < ApplicationController
  allow_unauthenticated_access only: %i[index new]

  def index
    @places = Place.all
  end

  def new
    @place = Place.new
    @place.place_hours.build # Initialize at least one empty place_hour for the form
    @categories = Category.all.order(:name)
    @countries = Country.where(active: true).order(:weight, :name)
  end

  def create
    @place = Place.new(place_params)
    @place.user = current_user if authenticated?

    if @place.save
      redirect_to places_path, notice: I18n.t("controllers.places.create.success")
    else
      @categories = Category.all.order(:name)
      @countries = Country.where(active: true).order(:weight, :name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def place_params
    params.require(:place).permit(
      :name, :description, :address, :city, :region, :postal_code, :country_id,
      :lat, :lng, :phone, :email, :url, :charity_support, :location_instructions,
      :pickup, :used_ok, :is_bin, :tax_receipt,
      category_ids: [],
      place_hours_attributes: [:id, :day_of_week, :from_hour, :to_hour, :_destroy]
    )
  end
end
