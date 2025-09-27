class AddUserReferenceToPlaceFeedbacks < ActiveRecord::Migration[8.0]
  def change
    add_reference :place_feedbacks, :user, null: false, foreign_key: true
  end
end
