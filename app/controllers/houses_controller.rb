class HousesController < ApplicationController
  before_action :require_site_admin

  def index
    @trip = params[:trip_id] ? Trip.find(params[:trip_id]) : Trip.current
    @houses = @trip.houses.includes(bedrooms: { beds: { golfer_trips: :golfer } })
  end

  def new
    @trip = Trip.find(params[:trip_id])
    @house = @trip.houses.new
  end

  def create
    trip = Trip.find(params[:trip_id])
    ActiveRecord::Base.transaction do
      @house = trip.houses.create!(house_params)
      build_beds(@house, (params[:new_beds] || {}).values)
    end
    redirect_to houses_path(trip_id: trip.id)
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.record.errors.full_messages.to_sentence
    redirect_to new_house_path(trip_id: trip.id)
  end

  def edit
    @house = House.find(params[:id])
    @trip = @house.trip
  end

  def update
    @house = House.find(params[:id])
    ActiveRecord::Base.transaction do
      @house.update!(house_params)
      update_beds(@house, params[:beds] || {})
      build_beds(@house, (params[:new_beds] || {}).values)
      @house.bedrooms.reload.each { |bedroom| bedroom.destroy if bedroom.beds.reload.empty? }
    end
    redirect_to houses_path(trip_id: @house.trip_id)
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.record.errors.full_messages.to_sentence
    redirect_to edit_house_path(@house)
  end

  def destroy
    house = House.find(params[:id])
    trip_id = house.trip_id
    house.destroy
    redirect_to houses_path(trip_id: trip_id)
  end

  private

  def house_params
    params.require(:house).permit(:name, :address, :url)
  end

  def build_beds(house, array)
    array.each do |attrs|
      next if attrs[:bedroom_name].blank? && attrs[:description].blank?
      bedroom = house.bedrooms.find_or_create_by!(name: attrs[:bedroom_name].to_s.strip)
      bedroom.beds.create!(
        description: attrs[:description],
        capacity: attrs[:capacity].to_i,
        rank: attrs[:rank].to_i
      )
    end
  end

  def update_beds(house, hash)
    beds = house.beds.where(id: hash.keys).index_by { |bed| bed.id.to_s }
    # Park updated beds on temporary ranks first so rank swaps don't clash mid-update
    Bed.where(id: beds.keys).update_all("rank = rank + 100000")
    hash.each do |id, attrs|
      bed = beds[id]
      next unless bed
      if attrs[:_destroy] == "1"
        bed.destroy
        next
      end
      bedroom = house.bedrooms.find_or_create_by!(name: attrs[:bedroom_name].to_s.strip)
      bed.update!(
        bedroom: bedroom,
        description: attrs[:description],
        capacity: attrs[:capacity].to_i,
        rank: attrs[:rank].to_i
      )
    end
  end
end
