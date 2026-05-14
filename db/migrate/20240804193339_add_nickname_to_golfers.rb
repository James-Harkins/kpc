class AddNicknameToGolfers < ActiveRecord::Migration[5.2]
  def change
    add_column :golfers, :nickname, :string
  end
end
