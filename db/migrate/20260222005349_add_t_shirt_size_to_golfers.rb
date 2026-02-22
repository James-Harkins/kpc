class AddTShirtSizeToGolfers < ActiveRecord::Migration[5.2]
  def change
    add_column :golfers, :t_shirt_size, :integer
  end
end
