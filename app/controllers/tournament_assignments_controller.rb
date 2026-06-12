class TournamentAssignmentsController < ApplicationController
  before_action :require_admin

  def update
    assignment = TournamentAssignment.find(params[:id])
    permitted  = params.permit(:team, :matchup_group)
    assignment.update!(permitted)
    redirect_to '/tournament', notice: 'Assignment updated.'
  end
end
