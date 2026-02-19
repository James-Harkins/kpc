class AddIndexToPasswordResetToken < ActiveRecord::Migration[5.2]
  def change
    add_index :golfers, :password_reset_token, unique: true,
              where: "password_reset_token IS NOT NULL"
  end
end
