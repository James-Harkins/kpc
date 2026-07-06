class CreateHouses < ActiveRecord::Migration[5.2]
  def change
    create_table :houses do |t|
      t.references :trip, null: false, foreign_key: true
      t.string :name, null: false
      t.string :address
      t.string :url
      t.timestamps
    end
  end
end
