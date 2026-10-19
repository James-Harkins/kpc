class PreviousTripsController < ApplicationController
  before_action :require_admin

  def index
    @trips = Trip.where(completed: true)
                 .order(number: :desc)
                 .includes(:trip_financial_summary, :nights, :rounds)
    @all_time_attendance = Trip.unique_attendance_across(@trips)
    summaries = @trips.map(&:trip_financial_summary).compact
    if summaries.any?
      @average_revenue = summaries.sum(&:total_revenue).to_f / summaries.size
      @average_expenses = summaries.sum(&:total_expenses).to_f / summaries.size
    end
  end
end
