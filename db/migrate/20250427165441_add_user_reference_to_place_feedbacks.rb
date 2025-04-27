class AddUserReferenceToPlaceFeedbacks < ActiveRecord::Migration[8.0]
  def change
    add_reference :place_feedbacks, :user, foreign_key: true
  end
end
