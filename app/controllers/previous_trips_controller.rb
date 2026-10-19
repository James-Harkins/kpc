class PreviousTripsController < ApplicationController
  before_action :require_admin

  def index
    @trips = Trip.where(completed: true)
                 .order(number: :desc)
                 .includes(:trip_financial_summary, :nights, :rounds)
    @all_time_attendance = Trip.unique_attendance_across(@trips)
  end
end
