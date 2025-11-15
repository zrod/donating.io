class RenameGeoTermToGeocoderCache < ActiveRecord::Migration[8.1]
  def change
    rename_table :geo_terms, :geocoder_caches
  end
end
