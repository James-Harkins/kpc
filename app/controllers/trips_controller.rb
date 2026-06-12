class TripsController < ApplicationController
  before_action :require_site_admin

  def new
    @trip = Trip.new
    @courses = Course.all.order(:name)
  end

  def create
    @trip = Trip.new(trip_params)
    if @trip.save
      build_nights(@trip, (params[:new_nights] || {}).values)
      build_rounds(@trip, (params[:new_rounds] || {}).values)
      redirect_to '/dashboard'
    else
      @courses = Course.all.order(:name)
      flash[:error] = @trip.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @trip = Trip.find(params[:id])
    @courses = Course.all.order(:name)
  end

  def update
    @trip = Trip.find(params[:id])
    if @trip.update(trip_params)
      update_nights(@trip, params[:nights] || {})
      update_rounds(@trip, params[:rounds] || {})
      build_nights(@trip, (params[:new_nights] || {}).values)
      build_rounds(@trip, (params[:new_rounds] || {}).values)
      redirect_to '/dashboard'
    else
      @courses = Course.all.order(:name)
      flash[:error] = @trip.errors.full_messages.to_sentence
      render :edit
    end
  end

  def complete
    trip = Trip.find(params[:id])
    trip.update!(completed: true)
    redirect_to "/dashboard"
  end

  private

  def trip_params
    params.require(:trip).permit(:year, :number, :location, :start_date)
  end

  def build_nights(trip, array)
    array.each do |attrs|
      next if attrs[:date].blank? && attrs[:cost].blank?
      trip.nights.create!(date: attrs[:date], cost: attrs[:cost].to_i)
    end
  end

  def build_rounds(trip, array)
    array.each do |attrs|
      next if attrs[:date].blank? && attrs[:cost].blank?
      course = resolve_course(attrs)
      trip.rounds.create!(
        date: attrs[:date],
        cost: attrs[:cost].to_i,
        tee_time: attrs[:tee_time],
        course: course,
        is_tournament_round: attrs[:is_tournament_round] == "1"
      )
    end
  end

  def update_nights(trip, hash)
    hash.each do |id, attrs|
      night = trip.nights.find_by(id: id)
      next unless night
      night.update!(date: attrs[:date], cost: attrs[:cost].to_i)
    end
  end

  def update_rounds(trip, hash)
    hash.each do |id, attrs|
      round = trip.rounds.find_by(id: id)
      next unless round
      course = resolve_course(attrs)
      round.update!(
        date: attrs[:date],
        cost: attrs[:cost].to_i,
        tee_time: attrs[:tee_time],
        course: course,
        is_tournament_round: attrs[:is_tournament_round] == "1"
      )
    end
  end

  def resolve_course(attrs)
    if attrs[:course_id] == 'new' && attrs[:new_course_name].present?
      Course.find_or_create_by!(name: attrs[:new_course_name]) do |c|
        c.address = attrs[:new_course_address]
      end
    elsif attrs[:course_id].present? && attrs[:course_id] != 'new' && attrs[:course_id] != ''
      Course.find_by(id: attrs[:course_id].to_i)
    else
      nil
    end
  end
end
