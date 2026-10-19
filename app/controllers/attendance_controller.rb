class AttendanceController < ApplicationController
  before_action :require_admin

  def index
    @next_trip = Trip.find(params[:trip_id])
    @show_open_beds = @next_trip == Trip.current && !@next_trip.completed?
    return unless @show_open_beds
    @total_bed_spots = @next_trip.total_bed_spots
    @open_bed_spots = @next_trip.open_bed_spots
    @open_beds_by_night = @next_trip.open_bed_spots_by_night
  end
end
