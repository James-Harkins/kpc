class CreateRounds < ActiveRecord::Migration[5.2]
  def change
    create_table :rounds do |t|
      t.date :date
      t.integer :cost
      t.references :trip, foreign_key: true

      t.timestamps
    end
  end
end
