class AddBalanceToGolferTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :golfer_trips, :balance, :integer
  end
end
