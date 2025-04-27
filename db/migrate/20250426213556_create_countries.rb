class CreateCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :iso_alpha3, index: { unique: true }
      t.integer :weight, default: 0, index: true
      t.boolean :active, default: false, index: true

      t.timestamps
    end
  end
end
