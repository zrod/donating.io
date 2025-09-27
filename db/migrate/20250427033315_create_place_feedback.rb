class CreatePlaceFeedback < ActiveRecord::Migration[8.0]
  def change
    create_table :place_feedbacks do |t|
      t.string :reason, null: false
      t.text :details
      t.belongs_to :place, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
