Rails.application.config.after_initialize do
  Geocoder.configure(
    timeout: 3,
    lookup: :nominatim,
    http_headers: {
      "User-Agent" => ENV.fetch("USER_AGENT", "dev-mode-update-me")
    },
    # ip_lookup: :ipinfo_io,
    language: :en,
    use_https: true,
    # http_proxy: nil,
    # https_proxy: nil,
    # api_key: nil,
    cache: GeocoderCache,

    # Exceptions that should not be rescued by default
    # (if you want to implement custom error handling);
    # supports SocketError and Timeout::Error
    always_raise: [
      SocketError,
      Timeout::Error,
      Geocoder::NetworkError,
      Geocoder::ServiceUnavailable
    ],

    # Calculation options
    units: :km,
    # distances: :linear # :spherical or :linear

    # Cache configuration
    cache_options: {
      expiration: 2.days,
      prefix: "geocoder:"
    }
  )
end
