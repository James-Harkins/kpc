class Round < ApplicationRecord
  belongs_to :trip
  belongs_to :course, optional: true
  has_many :golfer_rounds
  has_many :golfers, through: :golfer_rounds
  has_many :tournament_assignments
  has_many :tournament_matchup_results

  scope :tournament,     -> { where(is_tournament_round: true) }
  scope :non_tournament, -> { where(is_tournament_round: false) }
end
