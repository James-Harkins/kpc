class AddWelcomeTokenToGolfers < ActiveRecord::Migration[5.2]
  def change
    add_column :golfers, :welcome_token, :boolean, default: false, null: false
  end
end
