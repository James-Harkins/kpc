class AddGolferToExpenses < ActiveRecord::Migration[5.2]
  def change
    add_reference :expenses, :golfer, foreign_key: true
  end
end
