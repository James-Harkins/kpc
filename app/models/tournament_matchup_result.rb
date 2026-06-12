class TournamentMatchupResult < ApplicationRecord
  belongs_to :round

  validates :matchup_group, presence: true
  validates :result, inclusion: { in: %w[A B tie] }
  validates :matchup_group, uniqueness: { scope: :round_id }

  def self.team_points(trip)
    results = joins(round: :trip).where(rounds: { trip_id: trip.id })
    a_pts = results.sum { |r| r.result == "A" ? 1 : r.result == "tie" ? 0.5 : 0 }
    b_pts = results.sum { |r| r.result == "B" ? 1 : r.result == "tie" ? 0.5 : 0 }
    { "A" => a_pts, "B" => b_pts }
  end
end
