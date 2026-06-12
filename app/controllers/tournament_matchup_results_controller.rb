class TournamentMatchupResultsController < ApplicationController
  before_action :require_admin

  def update
    round = Round.find(params[:round_id])
    (params[:results] || {}).each do |matchup_group, result|
      next if result.blank?
      record = TournamentMatchupResult.find_or_initialize_by(
        round_id: round.id,
        matchup_group: matchup_group.to_i
      )
      record.update!(result: result)
    end
    redirect_to '/tournament', notice: 'Results saved.'
  end
end
