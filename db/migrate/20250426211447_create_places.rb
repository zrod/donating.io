class CreatePlaces < ActiveRecord::Migration[8.0]
  def change
    create_table :places do |t|
      t.string :name
      t.string :slug, index: { unique: true }
      t.text :description
      t.string :address
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :lng, precision: 10, scale: 6
      t.string :city
      t.string :region
      t.string :phone
      t.string :url
      t.string :logo
      t.string :postal_code
      t.string :email
      t.text :charity_support
      t.text :location_instructions
      t.boolean :pickup, default: false, index: true
      t.boolean :used_ok, default: true, index: true
      t.boolean :is_bin, default: false, index: true
      t.boolean :tax_receipt, default: false, index: true
      t.integer :osm_id
      t.integer :status, default: false, index: true

      t.timestamps
    end
  end
end
