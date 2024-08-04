class AddCostToGolferTrip < ActiveRecord::Migration[5.2]
  def change
    add_column :golfer_trips, :cost, :integer
  end
end
