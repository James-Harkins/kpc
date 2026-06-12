class AddScoreToGolferRounds < ActiveRecord::Migration[5.2]
  def change
    add_column :golfer_rounds, :score, :integer
  end
end
