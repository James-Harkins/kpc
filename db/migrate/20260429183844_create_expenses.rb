class CreateExpenses < ActiveRecord::Migration[5.2]
  def change
    create_table :expenses do |t|
      t.references :trip, foreign_key: true
      t.date :date
      t.integer :amount
      t.string :description
    end
  end
end
