class CreateBedAlertOptOuts < ActiveRecord::Migration[5.2]
  def change
    create_table :bed_alert_opt_outs do |t|
      t.references :golfer, null: false, foreign_key: true
      t.references :trip, null: false, foreign_key: true
      t.timestamps
    end
    add_index :bed_alert_opt_outs, [:golfer_id, :trip_id], unique: true
  end
end
