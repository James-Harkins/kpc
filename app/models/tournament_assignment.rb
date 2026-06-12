class TournamentAssignment < ApplicationRecord
  belongs_to :trip
  belongs_to :golfer
  belongs_to :round

  validates :team, inclusion: { in: %w[A B] }
  validates :matchup_group, presence: true
  validates :golfer_id, uniqueness: { scope: [:trip_id, :round_id] }

  # --- Algorithm ---

  TEAM_A_POSITIONS = {
    4 => [0, 3],
    3 => [0, 2],
    2 => [0],
  }.freeze

  MATCH_TYPE = { 4 => "2v2", 3 => "2v1", 2 => "1v1" }.freeze

  def self.generate_for_trip(trip)
    tournament_rounds = trip.rounds.tournament
    return if tournament_rounds.empty?

    participants = participant_golfer_ids(trip)
    ranked       = rank_participants(participants, trip)
    groups       = build_groups(ranked)

    transaction do
      where(trip_id: trip.id).destroy_all
      tournament_rounds.each do |round|
        apply_groups(groups, trip, round, trip.captain_a_id, trip.captain_b_id)
      end
    end
  end

  def self.generate_for_round(round, trip)
    participants = participant_golfer_ids(trip)
    ranked       = rank_participants(participants, trip)
    groups       = build_groups(ranked)

    transaction do
      where(trip_id: trip.id, round_id: round.id).destroy_all
      apply_groups(groups, trip, round, trip.captain_a_id, trip.captain_b_id)
    end
  end

  def self.apply_groups(groups, trip, round, captain_a_id = nil, captain_b_id = nil)
    assignments = []
    groups.each_with_index do |group, idx|
      group_num   = idx + 1
      size        = group.size
      a_positions = TEAM_A_POSITIONS[size]
      match_type  = MATCH_TYPE[size]

      group.each_with_index do |golfer_id, pos|
        team = a_positions.include?(pos) ? "A" : "B"
        assignments << { golfer_id: golfer_id, team: team,
                         matchup_group: group_num, match_type: match_type }
      end
    end

    fix_captain_teams!(assignments, captain_a_id, captain_b_id) if captain_a_id && captain_b_id

    assignments.each do |attrs|
      create!(trip_id: trip.id, round_id: round.id, **attrs)
    end
  end

  def self.build_groups(ranked)
    r = ranked.size % 4
    tail_sizes = { 0 => [], 2 => [2], 3 => [3], 1 => [3, 2] }[r]

    tail_count = tail_sizes.sum
    body = ranked[0...(ranked.size - tail_count)]
    tail = ranked[(ranked.size - tail_count)..]

    groups = body.each_slice(4).to_a
    tail_sizes.each do |sz|
      groups << tail.shift(sz)
    end
    groups
  end

  def self.average_ranking_score(golfer_id, trip)
    ids    = trip.rounds.non_tournament.pluck(:id)
    scores = GolferRound.where(golfer_id: golfer_id, round_id: ids)
                        .where.not(score: nil).pluck(:score)
    return scores.sum.to_f / scores.size if scores.any?

    prev = Trip.where("start_date < ?", trip.start_date).order(start_date: :desc).first
    return nil unless prev
    prev_ids    = prev.rounds.pluck(:id)
    prev_scores = GolferRound.where(golfer_id: golfer_id, round_id: prev_ids)
                             .where.not(score: nil).pluck(:score)
    prev_scores.any? ? prev_scores.sum.to_f / prev_scores.size : nil
  end

  private

  def self.participant_golfer_ids(trip)
    t_ids = trip.rounds.tournament.pluck(:id)
    GolferRound.where(round_id: t_ids).pluck(:golfer_id).uniq
  end

  def self.rank_participants(golfer_ids, trip)
    golfer_ids.sort_by { |id| average_ranking_score(id, trip) || Float::INFINITY }
  end

  def self.fix_captain_teams!(assignments, captain_a_id, captain_b_id)
    ca = assignments.find { |a| a[:golfer_id] == captain_a_id }
    cb = assignments.find { |a| a[:golfer_id] == captain_b_id }
    return unless ca && cb

    if ca[:team] == "B" && cb[:team] == "A"
      ca[:team] = "A"; cb[:team] = "B"
    elsif ca[:team] == "A" && cb[:team] == "A"
      partner = assignments.find { |a| a[:team] == "B" && a[:matchup_group] == cb[:matchup_group] } ||
                assignments.find { |a| a[:team] == "B" }
      if partner
        partner[:team] = "A"
        cb[:team] = "B"
      end
    elsif ca[:team] == "B" && cb[:team] == "B"
      partner = assignments.find { |a| a[:team] == "A" && a[:matchup_group] == ca[:matchup_group] } ||
                assignments.find { |a| a[:team] == "A" }
      if partner
        partner[:team] = "B"
        ca[:team] = "A"
      end
    end
    # ca == "A" && cb == "B": already correct, no action needed
  end
end
