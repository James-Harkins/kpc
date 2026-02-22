class AnnouncementsController < ApplicationController
  before_action :require_site_admin

  def new
    @trips = Trip.joins(:golfer_trips).distinct.order(number: :desc)
  end

  def create
    trip    = Trip.find(params[:trip_id])
    subject = params[:subject]
    body    = params[:body]

    trip.golfers.each do |golfer|
      GolferMailer.announcement(golfer, subject, body, trip).deliver_now
    end

    flash[:notice] = "Email sent to all golfers on KPC #{trip.number}!"
    redirect_to "/dashboard"
  end
end
