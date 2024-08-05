class FinancesController < ApplicationController
  def index
    @next_trip = Trip.find(params[:trip_id])
  end
end
