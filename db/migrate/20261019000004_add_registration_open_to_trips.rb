class AddRegistrationOpenToTrips < ActiveRecord::Migration[5.2]
  def up
    add_column :trips, :registration_open, :boolean, default: false, null: false
    # Trips already finished or underway stay open; any upcoming trip starts
    # closed so the admins can claim their beds first.
    execute "UPDATE trips SET registration_open = TRUE WHERE completed = TRUE OR start_date < NOW()"
  end

  def down
    remove_column :trips, :registration_open
  end
end
