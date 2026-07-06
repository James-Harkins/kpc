class AddDepositDueDateToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :deposit_due_date, :date
  end
end
