class ChangeReasonToIntegerInPlaceFeedbacks < ActiveRecord::Migration[8.0]
  def change
    change_column :place_feedbacks, :reason, :integer
  end
end
