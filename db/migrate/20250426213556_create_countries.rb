class CreateCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :countries do |t|
      t.string :name, null: false
      t.string :iso_alpha3, null: false, index: { unique: true }
      t.integer :weight, default: 0, index: true
      t.boolean :active, default: false, null: false, index: true

      t.timestamps
    end
  end
end
