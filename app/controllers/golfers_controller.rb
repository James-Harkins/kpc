class GolfersController < ApplicationController
  before_action :require_login, only: [:show]
  before_action :require_non_admin, only: [:edit, :update]

  def show
    @golfer = current_user
    @next_trip = Trip.current
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

  def edit
    @golfer = current_user
  end

  def update
    @golfer = current_user
    if @golfer.update(profile_params)
      flash[:notice] = "Profile updated!"
      redirect_to "/dashboard"
    else
      flash[:error] = @golfer.errors.full_messages.to_sentence
      redirect_to "/profile/edit"
    end
  end

  def golfer_params
    params.permit(:first_name, :last_name, :nickname, :email, :password, :password_confirmation, :t_shirt_size)
  end

  def profile_params
    params.permit(:email, :nickname, :t_shirt_size)
  end
end
