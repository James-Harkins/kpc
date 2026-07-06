class BedAssignmentsController < ApplicationController
  before_action :require_admin

  def index
    @trip = params[:trip_id] ? Trip.find(params[:trip_id]) : Trip.current
    @priority = @trip.bed_priority_order
    @houses = @trip.houses.includes(bedrooms: { beds: { golfer_trips: :golfer } })
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
          trip.golfer_trips.update_all(bed_id: nil)
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
end
