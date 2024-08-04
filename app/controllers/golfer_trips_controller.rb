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
    golfer = current_user
    trip = Trip.where('start_date > ?', Date.today).first
    golfer_trip = GolferTripFacade.create_new_golfer_trip(golfer, trip, params)

    if golfer_trip.save   
      golfer_trip.cost = golfer.trip_net_total_cost(trip.id)  
      golfer_trip.save
      redirect_to "/dashboard"
    else 
      redirect_to "/register_trip"
      flash[:error] = golfer.errors.full_messages.to_sentence + ", fucko!"
    end
  end
end