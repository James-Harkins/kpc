class AddIsTournamentRoundToRounds < ActiveRecord::Migration[5.2]
  def change
    add_column :rounds, :is_tournament_round, :boolean, default: false, null: false
  end
end
