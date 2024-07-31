class CreateGolferTrips < ActiveRecord::Migration[5.2]
  def change
    create_table :golfer_trips do |t|
      t.references :golfer, foreign_key: true
      t.references :trip, foreign_key: true

      t.timestamps
    end
  end
end
