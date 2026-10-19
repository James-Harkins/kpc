class ReserveAllWeekForAdminGolferTrips < ActiveRecord::Migration[5.2]
  def up
    execute <<~SQL
      UPDATE golfer_trips SET reserved_all_week = TRUE
      FROM golfers, trips
      WHERE golfer_trips.golfer_id = golfers.id
        AND golfer_trips.trip_id = trips.id
        AND golfers.role = 1
        AND trips.completed = FALSE
    SQL
  end

  def down
  end
end
