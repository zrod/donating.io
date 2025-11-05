class AddLatLngIndexToPlaces < ActiveRecord::Migration[8.1]
  def change
    add_index :places, [ :lat, :lng ]
  end
end
