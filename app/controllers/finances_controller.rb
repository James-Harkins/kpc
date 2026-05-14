class FinancesController < ApplicationController
  before_action :require_admin

  def index
    @next_trip = Trip.find(params[:trip_id])
    @summary   = @next_trip.trip_financial_summary
    if @summary
      @breakdown   = @next_trip.admin_cost_breakdown
      @settlements = @next_trip.admin_settlements
    end
  end
end
