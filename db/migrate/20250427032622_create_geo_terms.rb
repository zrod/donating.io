class CreateGeoTerms < ActiveRecord::Migration[8.0]
  def change
    create_table :geo_terms do |t|
      t.string :term, null: false, index: { unique: true }
      t.json :response, null: false
      t.timestamps
    end
  end
end
