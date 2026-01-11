json.places @places do |place|
  json.extract! place, :id, :name, :slug, :address, :city, :lat, :lng, :is_bin, :tax_receipt, :used_ok, :pickup
  json.has_charity_support place.has_charity_support
end

json.total @places_total
