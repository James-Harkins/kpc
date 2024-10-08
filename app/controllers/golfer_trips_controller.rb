class GolferTripsController < ApplicationController
  def new
    if current_user
      @next_trip = Trip.where('start_date > ?', Date.today).first

      if current_user.is_registered_for_next_trip(@next_trip)
        redirect_to "/dashboard"
        flash[:login] = "You're already signed up, Fucko!"  
      else 
        @trip = @next_trip.sort_by_calendar
      end
    else
      redirect_to "/login"
      flash[:login] = "Log in first, Fucko!"
    end
  end

  def create 
    golfer = current_user
    trip = Trip.where('start_date > ?', Date.today).first
    golfer_trip = GolferTripFacade.create_new_golfer_trip(golfer, trip, params)

    if golfer_trip.save   
      cost = golfer.trip_net_total_cost(trip.id)
      golfer_trip.cost = cost
      golfer_trip.balance = cost
      golfer_trip.save
      redirect_to "/dashboard"
    else 
      redirect_to "/register_trip"
      flash[:error] = golfer.errors.full_messages.to_sentence + ", Fucko!"
    end
  end

  def update 
    if params[:paid] == "true"
      golfer_trip = GolferTrip.find(params[:golfer_trip_id])
      golfer_trip.payments.create!(amount: golfer_trip.balance)
      golfer_trip.balance = 0
      golfer_trip.is_paid = true
      golfer_trip.save
      redirect_to "/finances?trip_id=#{golfer_trip.trip_id}"
    end
  end
end