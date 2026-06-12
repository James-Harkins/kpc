class AddCaptainsToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :captain_a_id, :bigint
    add_column :trips, :captain_b_id, :bigint
    add_foreign_key :trips, :golfers, column: :captain_a_id
    add_foreign_key :trips, :golfers, column: :captain_b_id
    add_index :trips, :captain_a_id
    add_index :trips, :captain_b_id
  end
end
