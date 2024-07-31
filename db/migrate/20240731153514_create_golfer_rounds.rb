class CreateGolferRounds < ActiveRecord::Migration[5.2]
  def change
    create_table :golfer_rounds do |t|
      t.references :golfer, foreign_key: true
      t.references :round, foreign_key: true

      t.timestamps
    end
  end
end
