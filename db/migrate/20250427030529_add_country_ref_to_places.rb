class AddCountryRefToPlaces < ActiveRecord::Migration[8.0]
  def change
    add_reference :places, :country, null: false, foreign_key: true
  end
end
