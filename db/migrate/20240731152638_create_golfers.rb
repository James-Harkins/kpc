class CreateGolfers < ActiveRecord::Migration[5.2]
  def change
    create_table :golfers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password_digest
      t.integer :role

      t.timestamps
    end
  end
end
