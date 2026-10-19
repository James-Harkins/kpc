class AddReservedAllWeekToGolferTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :golfer_trips, :reserved_all_week, :boolean, default: false, null: false
  end
end
