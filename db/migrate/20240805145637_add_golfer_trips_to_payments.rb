class AddGolferTripsToPayments < ActiveRecord::Migration[5.2]
  def change
    add_reference :payments, :golfer_trip, foreign_key: true
  end
end
