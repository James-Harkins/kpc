class AddUniqueIndexesToGolferSignups < ActiveRecord::Migration[5.2]
  def change
    # Remove duplicate golfer_nights, keeping the earliest record per (golfer_id, night_id)
    execute <<-SQL
      DELETE FROM golfer_nights
      WHERE id NOT IN (
        SELECT MIN(id) FROM golfer_nights GROUP BY golfer_id, night_id
      )
    SQL

    # Remove duplicate golfer_rounds, keeping the earliest record per (golfer_id, round_id)
    execute <<-SQL
      DELETE FROM golfer_rounds
      WHERE id NOT IN (
        SELECT MIN(id) FROM golfer_rounds GROUP BY golfer_id, round_id
      )
    SQL

    # Remove duplicate golfer_trips, keeping the earliest record per (golfer_id, trip_id)
    execute <<-SQL
      DELETE FROM golfer_trips
      WHERE id NOT IN (
        SELECT MIN(id) FROM golfer_trips GROUP BY golfer_id, trip_id
      )
    SQL

    add_index :golfer_nights, [:golfer_id, :night_id], unique: true,
              name: "index_golfer_nights_on_golfer_id_and_night_id"
    add_index :golfer_rounds, [:golfer_id, :round_id], unique: true,
              name: "index_golfer_rounds_on_golfer_id_and_round_id"
    add_index :golfer_trips, [:golfer_id, :trip_id], unique: true,
              name: "index_golfer_trips_on_golfer_id_and_trip_id"
  end
end
