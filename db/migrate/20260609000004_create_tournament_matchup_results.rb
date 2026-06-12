class CreateTournamentMatchupResults < ActiveRecord::Migration[5.2]
  def change
    create_table :tournament_matchup_results do |t|
      t.references :round,  null: false, foreign_key: true
      t.integer :matchup_group, null: false
      t.string  :result,    null: false
      t.timestamps
    end
    add_index :tournament_matchup_results, [:round_id, :matchup_group], unique: true,
              name: 'index_tournament_matchup_results_on_round_and_group'
  end
end
