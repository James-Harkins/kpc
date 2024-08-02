class AddIsFullNightToGolferTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :golfer_trips, :is_full_trip, :boolean
  end
end
