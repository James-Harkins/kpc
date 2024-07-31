class ChangeRoleOnGolfers < ActiveRecord::Migration[5.2]
  def change
    change_column :golfers, :role, :integer, :default => 0
  end
end
