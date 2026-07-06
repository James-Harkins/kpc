class AddBedToGolferTrips < ActiveRecord::Migration[5.2]
  def change
    add_reference :golfer_trips, :bed, foreign_key: true
  end
end
