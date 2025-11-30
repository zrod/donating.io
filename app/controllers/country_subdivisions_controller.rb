class CountrySubdivisionsController < ApplicationController
  CACHE_TTL = 1.week

  allow_unauthenticated_access

  def index
    country_id = params[:country_id].to_i
    @subdivisions = country_id.positive? ? cached_subdivisions(country_id) : []
    @region_value = params[:region_value].to_s.strip
  end

  private
    def cached_subdivisions(country_id)
      cache_key = ["country_subdivisions", Digest::SHA256.hexdigest(country_id.to_s)]

      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
        country = Country.find_by(id: country_id)
        return [] unless country

        Rails.cache.fetch(["country_subdivisions_data", country.cache_key_with_version], expires_in: CACHE_TTL) do
          country.country_subdivisions.order(:name).to_a
        end
      end
    end
end
