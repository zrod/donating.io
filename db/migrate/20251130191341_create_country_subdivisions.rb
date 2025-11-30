class CreateCountrySubdivisions < ActiveRecord::Migration[8.1]
  def change
    create_table :country_subdivisions do |t|
      t.references :country, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.string :code, limit: 10, null: false
      t.string :subdivision_type, limit: 50

      t.timestamps
    end

    add_index :country_subdivisions, [:country_id, :code], unique: true
    add_index :country_subdivisions, :subdivision_type
  end
end
