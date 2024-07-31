class CreateTrips < ActiveRecord::Migration[5.2]
  def change
    create_table :trips do |t|
      t.integer :year
      t.integer :number
      t.string :location

      t.timestamps
    end
  end
end
