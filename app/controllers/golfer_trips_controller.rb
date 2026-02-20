class GolferTripsController < ApplicationController
  before_action :require_login, only: [:new, :create]
  before_action :require_admin,  only: [:update]

  def new
    @next_trip = Trip.where('start_date > ?', Date.today).first
    if current_user.is_registered_for_next_trip(@next_trip)
      flash[:login] = "You're already signed up, Fucko!"
      redirect_to "/dashboard"
    else
      @trip = @next_trip.sort_by_calendar
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
      GolferMailer.trip_signup(golfer, golfer_trip).deliver_now
      redirect_to "/dashboard"
    else
      flash[:error] = golfer.errors.full_messages.to_sentence + ", Fucko!"
      redirect_to "/register_trip"
    end
  end

  def update
    if params[:paid] == "true"
      golfer_trip = GolferTrip.find(params[:golfer_trip_id])
      golfer_trip.payments.create!(amount: golfer_trip.balance)
      golfer_trip.balance = 0
      golfer_trip.is_paid = true
      golfer_trip.save
      GolferMailer.balance_paid(golfer_trip.golfer, golfer_trip).deliver_now
      redirect_to "/finances?trip_id=#{golfer_trip.trip_id}"
    end
  end
end
