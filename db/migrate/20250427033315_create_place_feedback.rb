class CreatePlaceFeedback < ActiveRecord::Migration[8.0]
  def change
    create_table :place_feedbacks do |t|
      t.string :reason
      t.text :details
      t.belongs_to :place, index: true, foreign_key: true

      t.timestamps
    end
  end
end
