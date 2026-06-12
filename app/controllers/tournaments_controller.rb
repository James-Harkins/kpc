class TournamentsController < ApplicationController
  before_action :require_admin

  def index
    @trip = Trip.current
    return unless @trip

    tournament_rounds = @trip.rounds.tournament.order(:date).includes(:course)
    all_assignments   = TournamentAssignment.where(trip_id: @trip.id)
                          .includes(:golfer, :round).to_a

    # Group assignments: { round_id => { matchup_group => [assignments] } }
    @assignments_by_round = tournament_rounds.each_with_object({}) do |round, h|
      grouped = all_assignments.select { |a| a.round_id == round.id }
                               .group_by(&:matchup_group)
      h[round.id] = grouped
    end

    @tournament_rounds = tournament_rounds

    all_results = TournamentMatchupResult.joins(:round)
                    .where(rounds: { trip_id: @trip.id }).to_a

    @results_by_round = all_results.each_with_object({}) do |r, h|
      h[r.round_id] ||= {}
      h[r.round_id][r.matchup_group] = r
    end

    @team_points = TournamentMatchupResult.team_points(@trip) if all_results.any?

    participant_ids = all_assignments.map(&:golfer_id).uniq
    @ranked_players = participant_ids.map do |golfer_id|
      avg = TournamentAssignment.average_ranking_score(golfer_id, @trip)
      source = score_source_label(golfer_id, @trip)
      { golfer: Golfer.find(golfer_id), avg_score: avg, source: source }
    end.sort_by { |p| p[:avg_score] || Float::INFINITY }

    @has_assignments = all_assignments.any?
    @team_a_name = @trip.team_a_name.presence || "Team A"
    @team_b_name = @trip.team_b_name.presence || "Team B"
    @trip_golfers = @trip.golfers.order('golfers.last_name, golfers.first_name')
  end

  def update_captains
    trip = Trip.current
    if trip
      captain_a = Golfer.find_by(id: params[:captain_a_id])
      captain_b = Golfer.find_by(id: params[:captain_b_id])

      if captain_a && captain_b && captain_a == captain_b
        redirect_to '/tournament', alert: 'Captains must be different golfers.'
        return
      end

      trip.update!(
        captain_a_id: params[:captain_a_id].presence,
        captain_b_id: params[:captain_b_id].presence,
        team_a_name: captain_a ? "Team #{captain_a.nickname.titleize}" : trip.team_a_name,
        team_b_name: captain_b ? "Team #{captain_b.nickname.titleize}" : trip.team_b_name
      )
    end
    redirect_to '/tournament', notice: 'Captains updated.'
  end

  def generate
    trip = Trip.current
    TournamentAssignment.generate_for_trip(trip) if trip
    redirect_to '/tournament', notice: 'Teams generated.'
  end

  def redraw
    trip  = Trip.current
    round = Round.find(params[:round_id])
    TournamentAssignment.generate_for_round(round, trip) if trip
    redirect_to '/tournament', notice: "Pairings redrawn for #{round.date.strftime('%B %-d')}."
  end

  private

  def score_source_label(golfer_id, trip)
    ids    = trip.rounds.non_tournament.pluck(:id)
    scores = GolferRound.where(golfer_id: golfer_id, round_id: ids).where.not(score: nil)
    return "#{trip.year} trip" if scores.any?

    prev = Trip.where("start_date < ?", trip.start_date).order(start_date: :desc).first
    if prev
      prev_scores = GolferRound.where(golfer_id: golfer_id, round_id: prev.rounds.pluck(:id))
                               .where.not(score: nil)
      return "#{prev.year} trip — fallback" if prev_scores.any?
    end

    "no history"
  end
end
