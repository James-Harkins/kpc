class CreateTournamentAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :tournament_assignments do |t|
      t.references :trip,   null: false, foreign_key: true
      t.references :golfer, null: false, foreign_key: true
      t.references :round,  null: false, foreign_key: true
      t.string  :team,          null: false
      t.integer :matchup_group, null: false
      t.string  :match_type,    null: false
      t.timestamps
    end
    add_index :tournament_assignments, [:trip_id, :golfer_id, :round_id], unique: true,
              name: 'index_tournament_assignments_on_trip_golfer_round'
  end
end
