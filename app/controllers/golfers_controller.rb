class GolfersController < ApplicationController
  def show
    if current_user
      @golfer = current_user
      @next_trip = Trip.where('start_date > ?', Date.today).first
      @golfer_next_trip = @golfer.golfer_trips.where(trip_id: @next_trip.id).first
    else
      redirect_to "/login"
      flash[:login] = "Log in first, Fucko!"
    end
  end

  def new
  end

  def create
    golfer = Golfer.new(golfer_params)
    if golfer.save
      redirect_to "/login"
    else
      redirect_to "/register"
      flash[:error] = golfer.errors.full_messages.to_sentence + ", Fucko!"
    end
  end

  def golfer_params
    params.permit(:first_name, :last_name, :nickname, :email, :password, :password_confirmation)
  end
end
