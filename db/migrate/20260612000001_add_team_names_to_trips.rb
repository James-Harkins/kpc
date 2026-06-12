class AddTeamNamesToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :team_a_name, :string
    add_column :trips, :team_b_name, :string
  end
end
