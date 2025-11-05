class ReCreateGeoTerms < ActiveRecord::Migration[8.1]
  def change
    drop_table :geo_terms, if_exists: true
    create_table :geo_terms, id: false do |t|
      t.string :url, null: false, primary_key: true
      t.json :response, null: false
      t.timestamps
    end
  end
end
