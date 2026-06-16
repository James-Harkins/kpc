class ScoreboardsController < ApplicationController
  before_action :require_admin

  def index
    @trip = Trip.current
    return unless @trip

    @rounds = @trip.rounds.non_tournament.order(:date).includes(:course)

    round_ids = @rounds.map(&:id)
    golfer_rounds = GolferRound.where(round_id: round_ids)

    golfer_ids = golfer_rounds.map(&:golfer_id).uniq
    golfers = Golfer.where(id: golfer_ids)

    @scores = golfer_rounds.each_with_object({}) do |gr, h|
      h[gr.golfer_id] ||= {}
      h[gr.golfer_id][gr.round_id] = gr.score
    end

    @golfers = golfers.sort_by do |g|
      scores = @scores[g.id]&.values&.compact || []
      avg = scores.any? ? scores.sum.to_f / scores.size : Float::INFINITY
      [avg, g.last_name]
    end
  end
end
