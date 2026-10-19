class BedAssignmentsController < ApplicationController
  before_action :require_admin

  def index
    @trip = params[:trip_id] ? Trip.find(params[:trip_id]) : Trip.current
    @priority = @trip.bed_priority_order
    @houses = @trip.houses.includes(bedrooms: { beds: { golfer_trips: :golfer } })
  end

  # Read-only grid of every bed across the whole stay. A bed stays reserved for
  # its assigned golfer all week, so nights they're away show as "away", not open.
  def week
    @trip = params[:trip_id] ? Trip.find(params[:trip_id]) : Trip.current
    @nights = @trip.nights.order(:date).to_a
    @houses = @trip.houses.includes(bedrooms: { beds: { golfer_trips: :golfer } })
    attending = GolferNight.where(night_id: @nights.map(&:id)).pluck(:golfer_id, :night_id)
    @attending = attending.to_set
    @attending_by_night = attending.group_by(&:last).transform_values(&:count)
    @unassigned = @trip.golfer_trips.where(bed_id: nil).includes(:golfer).sort_by { |golfer_trip| golfer_trip.golfer.nickname.to_s }
    @total_spots = @trip.beds.sum(:capacity)
    @slot_grids = @houses.flat_map { |house| house.bedrooms.flat_map(&:beds) }.index_by(&:id).transform_values { |bed| slot_grid(bed) }
  end

  def update
    trip = Trip.find(params[:trip_id])
    submitted = params[:beds].present? ? params[:beds].to_unsafe_h : {}
    chosen = submitted.values.flatten.reject(&:blank?)

    if chosen.length != chosen.uniq.length
      flash[:error] = "The same golfer was assigned to more than one bed slot. No changes were saved."
    else
      begin
        GolferTrip.transaction do
          trip.golfer_trips.update_all(bed_id: nil, reserved_all_week: false)
          trip.golfer_trips.where(id: Array(params[:reserved_all_week])).update_all(reserved_all_week: true)
          submitted.each do |bed_id, golfer_trip_ids|
            golfer_trip_ids.reject(&:blank?).each do |golfer_trip_id|
              trip.golfer_trips.find(golfer_trip_id).update!(bed_id: bed_id)
            end
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = e.record.errors.full_messages.to_sentence + ". No changes were saved."
      end
    end

    redirect_to bed_assignments_path(trip_id: trip.id)
  end

  private

  # One hash per sleeping slot of the bed: night_id => the golfer_trip in it that night.
  # Golfers whose nights don't overlap (or who are away and not reserved) share a slot.
  def slot_grid(bed)
    slots = Array.new(bed.capacity) { {} }
    bed.golfer_trips.sort_by(&:id).each do |golfer_trip|
      held = @nights.select { |night| golfer_trip.reserved_all_week? || @attending.include?([golfer_trip.golfer_id, night.id]) }.map(&:id)
      slot = slots.find { |taken| (taken.keys & held).empty? }
      held.each { |night_id| slot[night_id] = golfer_trip } if slot
    end
    slots
  end
end
