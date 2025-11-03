module PlacesHelper
  MAP_DIRECTION_PROVIDERS = [
    {
      name: "OpenStreetMap",
      url: ->(place) { "https://www.openstreetmap.org/directions?from=&to=#{place.lat}%2C#{place.lng}" }
    },
    {
      name: "Google Maps",
      url: ->(place) { "https://www.google.com/maps/dir/?api=1&destination=#{ERB::Util.url_encode(place.full_address)}" }
    },
    {
      name: "Bing Maps",
      url: ->(place) { "https://bing.com/maps/default.aspx?rtp=~pos.#{place.lat}_#{place.lng}" }
    },
    {
      name: "Apple Maps",
      url: ->(place) { "https://maps.apple.com/?daddr=#{place.lat},#{place.lng}" }
    }
  ]

  def format_hour(hour_string)
    return "" if hour_string.blank?

    hour = hour_string.to_i
    hours = hour / 100
    minutes = hour % 100

    Time.new(2000, 1, 1, hours, minutes).strftime("%l:%M %P").strip
  end

  def map_directions_list(place)
    MAP_DIRECTION_PROVIDERS.map do |provider|
      {
        name: provider[:name],
        url: provider[:url].call(place)
      }
    end
  end
end
