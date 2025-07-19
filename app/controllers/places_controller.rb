class PlacesController < ApplicationController
  allow_unauthenticated_access only: %i[index]

  def index
    @places = Place.all
  end
end
