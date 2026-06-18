class GolfersController < ApplicationController
  before_action :require_login, only: [:show]
  before_action :require_non_admin, only: [:edit, :update]
  before_action :require_site_admin, only: [:admin_new, :admin_create]

  def show
    @golfer = current_user
    @next_trip = Trip.current
    @golfer_next_trip = @next_trip && @golfer.golfer_trips.where(trip_id: @next_trip.id).first
    @last_completed_trip = @next_trip.nil? ? Trip.where(completed: true).order(id: :desc).first : nil
    @editable_trips = Trip.where('start_date >= ?', Date.today).order(:start_date)
  end

  def new
  end

  def create
    if params[:token] == ENV["REGISTER_TOKEN"]
      golfer = Golfer.new(golfer_params)
      if golfer.save
        redirect_to "/login"
      else
        flash[:error] = golfer.errors.full_messages.to_sentence + "."
        redirect_to "/register"
      end
    else
      flash[:error] = "Invitation only."
      redirect_to "/register"
    end
  end

  def admin_new
    @golfer = Golfer.new
  end

  def admin_create
    golfer = Golfer.new(admin_golfer_params)
    temp_password = SecureRandom.urlsafe_base64(24)
    golfer.password = temp_password
    golfer.password_confirmation = temp_password
    if golfer.save
      raw_token = golfer.generate_password_reset_token!
      golfer.update_columns(welcome_token: true)
      GolferMailer.welcome(golfer, raw_token).deliver_now
      flash[:notice] = "Golfer account created. Welcome email sent to #{golfer.email}."
      redirect_to "/dashboard"
    else
      flash[:error] = golfer.errors.full_messages.to_sentence
      redirect_to "/admin/golfer/new"
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

  def admin_golfer_params
    params.permit(:first_name, :last_name, :nickname, :email, :t_shirt_size)
  end
end
