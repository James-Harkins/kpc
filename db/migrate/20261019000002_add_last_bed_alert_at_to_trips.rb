class AddLastBedAlertAtToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :last_bed_alert_at, :datetime
  end
end
