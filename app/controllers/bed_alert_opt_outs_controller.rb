class BedAlertOptOutsController < ApplicationController
  before_action :load_parties

  def show
  end

  def create
    BedAlertOptOut.find_or_create_by!(golfer: @golfer, trip: @trip)
  end

  private

  def load_parties
    @golfer, @trip = BedAlertOptOut.parties_for(params[:token])
    render plain: "This link is invalid or has expired.", status: :not_found unless @golfer
  end
end
