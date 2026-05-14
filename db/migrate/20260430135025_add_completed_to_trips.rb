class AddCompletedToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :completed, :boolean, default: false, null: false
  end
end
