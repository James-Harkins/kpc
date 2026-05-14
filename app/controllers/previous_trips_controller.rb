class PreviousTripsController < ApplicationController
  before_action :require_admin

  def index
    @trips = Trip.where(completed: true)
                 .order(number: :desc)
                 .includes(:trip_financial_summary, :nights, :rounds)
  end
end
