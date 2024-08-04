class AddIsPaidToGolferTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :golfer_trips, :is_paid, :boolean, :default => false
  end
end
