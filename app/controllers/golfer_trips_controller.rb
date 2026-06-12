class GolferTripsController < ApplicationController
  before_action :require_login, only: [:new, :create]
  before_action :require_admin,  only: [:update]
  before_action :require_site_admin, only: [:edit, :admin_update]

  def new
    @next_trip = Trip.current
    if @next_trip.nil?
      flash[:login] = "No trip is currently open for registration."
      redirect_to '/dashboard' and return
    end
    if current_user.is_registered_for_next_trip(@next_trip)
      flash[:login] = "You're already signed up."
      redirect_to "/dashboard"
    else
      @trip = @next_trip.sort_by_calendar
    end
  end

  def create
    golfer = current_user
    trip = Trip.current
    if trip.nil?
      redirect_to '/dashboard' and return
    end
    golfer_trip = GolferTripFacade.create_new_golfer_trip(golfer, trip, params)

    if golfer_trip.save
      if golfer.admin?
        golfer_trip.cost    = 0
        golfer_trip.balance = 0
        golfer_trip.is_paid = true
      else
        golfer_trip.cost    = golfer.trip_net_total_cost(trip.id)
        golfer_trip.balance = golfer_trip.cost
      end
      golfer_trip.save
      GolferMailer.trip_signup(golfer, golfer_trip).deliver_now unless golfer.admin?
      redirect_to "/dashboard"
    else
      flash[:error] = golfer.errors.full_messages.to_sentence + "."
      redirect_to "/register_trip"
    end
  end

  def update
    if params[:paid] == "true"
      golfer_trip = GolferTrip.find(params[:golfer_trip_id])
      total_paid = golfer_trip.payments.sum(:amount)
      remaining = [golfer_trip.cost - total_paid, 0].max
      golfer_trip.payments.create!(amount: remaining)
      golfer_trip.balance = 0
      golfer_trip.is_paid = true
      golfer_trip.save!
      GolferMailer.balance_paid(golfer_trip.golfer, golfer_trip).deliver_now
      redirect_to "/finances?trip_id=#{golfer_trip.trip_id}"
    end
  end

  def edit
    @golfer_trip = GolferTrip.find(params[:id])
    @trip = @golfer_trip.trip
    @golfer = @golfer_trip.golfer
    @total_paid = @golfer_trip.payments.sum(:amount)
    @selected_night_ids = GolferNight.where(golfer_id: @golfer.id)
                                     .joins(:night)
                                     .where(nights: { trip_id: @trip.id })
                                     .pluck(:night_id)
    @selected_round_ids = GolferRound.where(golfer_id: @golfer.id)
                                     .joins(:round)
                                     .where(rounds: { trip_id: @trip.id })
                                     .pluck(:round_id)
  end

  def admin_update
    @golfer_trip = GolferTrip.find(params[:id])
    @trip = @golfer_trip.trip
    @golfer = @golfer_trip.golfer

    valid_night_ids = @trip.nights.pluck(:id)
    valid_round_ids = @trip.rounds.pluck(:id)

    submitted_night_ids = (params[:nights] || []).map(&:to_i).select { |id| valid_night_ids.include?(id) }
    submitted_round_ids = (params[:rounds] || []).map(&:to_i).select { |id| valid_round_ids.include?(id) }

    nights_cost = Night.where(id: submitted_night_ids).sum(:cost)
    rounds_cost = Round.where(id: submitted_round_ids).sum(:cost)
    gross_cost = nights_cost + rounds_cost

    is_full_trip = (submitted_night_ids.sort == valid_night_ids.sort &&
                    submitted_round_ids.sort == valid_round_ids.sort)

    first_night_cost = is_full_trip ? (@trip.nights.order(:date).first&.cost || 0) : 0
    new_cost = gross_cost - first_night_cost

    @total_paid = @golfer_trip.payments.sum(:amount)

    if new_cost < @total_paid && params[:confirm_overpayment] != '1'
      @overpayment_warning = true
      @selected_night_ids = submitted_night_ids
      @selected_round_ids = submitted_round_ids
      render :edit
      return
    end

    current_night_ids = GolferNight.where(golfer_id: @golfer.id)
                                   .joins(:night)
                                   .where(nights: { trip_id: @trip.id })
                                   .pluck(:night_id)
    current_round_ids = GolferRound.where(golfer_id: @golfer.id)
                                   .joins(:round)
                                   .where(rounds: { trip_id: @trip.id })
                                   .pluck(:round_id)

    nights_to_remove = current_night_ids - submitted_night_ids
    nights_to_add    = submitted_night_ids - current_night_ids
    rounds_to_remove = current_round_ids - submitted_round_ids
    rounds_to_add    = submitted_round_ids - current_round_ids

    GolferNight.where(golfer_id: @golfer.id, night_id: nights_to_remove).destroy_all
    nights_to_add.each { |nid| GolferNight.find_or_create_by!(golfer_id: @golfer.id, night_id: nid) }

    GolferRound.where(golfer_id: @golfer.id, round_id: rounds_to_remove).destroy_all
    rounds_to_add.each { |rid| GolferRound.find_or_create_by!(golfer_id: @golfer.id, round_id: rid) }

    new_balance = [new_cost - @total_paid, 0].max
    new_is_paid = new_balance == 0

    if @golfer.admin?
      @golfer_trip.cost         = 0
      @golfer_trip.balance      = 0
      @golfer_trip.is_full_trip = is_full_trip
      @golfer_trip.is_paid      = true
    else
      @golfer_trip.cost         = new_cost
      @golfer_trip.balance      = new_balance
      @golfer_trip.is_full_trip = is_full_trip
      @golfer_trip.is_paid      = new_is_paid
    end
    @golfer_trip.save!

    redirect_to "/finances?trip_id=#{@trip.id}"
  end
end
