class GolferRoundsController < ApplicationController
  before_action :require_admin

  def edit
    @round = Round.find(params[:id])
    if @round.is_tournament_round?
      redirect_to '/dashboard', alert: 'Scores are not tracked for tournament rounds.'
      return
    end
    @golfer_rounds = @round.golfer_rounds.includes(:golfer).order('golfers.last_name, golfers.first_name')
  end

  def update
    @round = Round.find(params[:id])
    if @round.is_tournament_round?
      redirect_to '/dashboard', alert: 'Scores are not tracked for tournament rounds.'
      return
    end
    (params[:scores] || {}).each do |golfer_round_id, score|
      gr = GolferRound.find_by(id: golfer_round_id, round_id: @round.id)
      next unless gr
      gr.update!(score: score.presence ? score.to_i : nil)
    end
    flash[:notice] = 'Scores saved.'
    redirect_to edit_round_scores_path(@round)
  end
end
