class GolfersController < ApplicationController
  before_action :require_login, only: [:show]

  def show
    @golfer = current_user
    @next_trip = Trip.where('start_date > ?', Date.today).first
    @golfer_next_trip = @golfer.golfer_trips.where(trip_id: @next_trip.id).first
  end

  def new
  end

  def create
    if params[:token] == ENV["REGISTER_TOKEN"]
      golfer = Golfer.new(golfer_params)
      if golfer.save
        redirect_to "/login"
      else
        flash[:error] = golfer.errors.full_messages.to_sentence + ", Fucko!"
        redirect_to "/register"
      end
    else
      flash[:error] = "Invitation only."
      redirect_to "/register"
    end
  end

  def golfer_params
    params.permit(:first_name, :last_name, :nickname, :email, :password, :password_confirmation)
  end
end
