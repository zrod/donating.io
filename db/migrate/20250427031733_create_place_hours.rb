class CreatePlaceHours < ActiveRecord::Migration[8.0]
  def change
    create_table :place_hours do |t|
      t.belongs_to :place, index: true, foreign_key: true
      t.integer :from_hour, index: true
      t.integer :to_hour, index: true
      t.integer :day, index: true
    end

    add_index :place_hours, [ :place_id, :day, :from_hour, :to_hour ], unique: true
  end
end
