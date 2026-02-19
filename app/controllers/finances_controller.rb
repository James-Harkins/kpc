class FinancesController < ApplicationController
  before_action :require_admin

  def index
    @next_trip = Trip.find(params[:trip_id])
  end
end
