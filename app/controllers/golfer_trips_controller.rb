class GolferTripsController < ApplicationController
  def new
    if current_user
      @next_trip = Trip.where('start_date > ?', Date.today).first
      @trip = @next_trip.sort_by_calendar
    else
      redirect_to "/login"
      flash[:login] = "Log in first, fucko!"
    end
  end

  def create 
    binding.pry
  end
end