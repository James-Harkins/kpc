class CreateGolferNights < ActiveRecord::Migration[5.2]
  def change
    create_table :golfer_nights do |t|
      t.references :golfer, foreign_key: true
      t.references :night, foreign_key: true

      t.timestamps
    end
  end
end
