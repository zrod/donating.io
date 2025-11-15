class GeoTermLookupJob < ApplicationJob
  queue_as :geo_term_lookup

  limits_concurrency to: 1, duration: 1.second

  def perform(search_term)
    # Do something later
  end
end
