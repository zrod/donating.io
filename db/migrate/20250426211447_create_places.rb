class CreatePlaces < ActiveRecord::Migration[8.0]
  def change
    create_table :places do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.text :description, null: false
      t.string :address, null: false
      t.decimal :lat, null: false, precision: 10, scale: 6
      t.decimal :lng, null: false, precision: 10, scale: 6
      t.string :city, null: false
      t.string :region
      t.string :phone
      t.string :url
      t.string :logo
      t.string :postal_code
      t.string :email
      t.text :charity_support
      t.text :location_instructions
      t.boolean :pickup, default: false, null: false, index: true
      t.boolean :used_ok, default: true, null: false, index: true
      t.boolean :is_bin, default: false, null: false, index: true
      t.boolean :tax_receipt, default: false, null: false, index: true
      t.integer :osm_id
      t.integer :status, default: false, null: false, index: true

      t.timestamps
    end
  end
end
