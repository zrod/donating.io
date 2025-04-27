class CreateCategoriesPlaces < ActiveRecord::Migration[8.0]
  def change
    create_table :categories_places do |t|
      t.belongs_to :category, index: true
      t.belongs_to :place, index: true
      t.timestamps
    end

    add_index :categories_places, [ :category_id, :place_id ], unique: true
  end
end
