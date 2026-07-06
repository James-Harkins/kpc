class AddDepositPolicyAcknowledgedAtToGolferTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :golfer_trips, :deposit_policy_acknowledged_at, :datetime
  end
end
