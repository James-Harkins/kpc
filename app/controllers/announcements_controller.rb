class AnnouncementsController < ApplicationController
  before_action :require_site_admin

  def new
    @trips = Trip.joins(:golfer_trips).distinct.order(number: :desc)
  end

  def create
    subject = params[:subject]
    body    = params[:body]

    if params[:trip_id] == "all"
      BulkMailJob.perform_later('announcement', Golfer.ids, subject, body, nil)
      flash[:notice] = "Email is being sent to all golfers!"
    else
      trip = Trip.find(params[:trip_id])
      recipient_ids = (trip.golfers.ids + Golfer.admin.ids).uniq
      BulkMailJob.perform_later('announcement', recipient_ids, subject, body, trip)
      flash[:notice] = "Email is being sent to all golfers on KPC #{trip.number}!"
    end

    redirect_to "/dashboard"
  end
end
