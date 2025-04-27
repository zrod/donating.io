class CreateTerms < ActiveRecord::Migration[8.0]
  def change
    create_table :terms do |t|
      t.string :term, index: { unique: true }
      t.text :response
      t.timestamps
    end
  end
end
