class CreateGeocoderCaches < ActiveRecord::Migration[8.1]
  def change
    create_table :geocoder_caches, id: false do |t|
      t.string :url, null: false, primary_key: true
      t.json :response, null: false
      t.timestamps
    end
  end
end
