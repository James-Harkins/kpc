class AnnouncementsController < ApplicationController
  before_action :require_site_admin

  def new
    @trips = Trip.joins(:golfer_trips).distinct.order(number: :desc)
  end

  def create
    subject = params[:subject]
    body    = params[:body]

    if params[:trip_id] == "all"
      Golfer.all.each do |golfer|
        GolferMailer.announcement(golfer, subject, body, nil).deliver_now
        sleep(0.6)
      end
      flash[:notice] = "Email sent to all golfers!"
    else
      trip = Trip.find(params[:trip_id])

      trip.golfers.each do |golfer|
        GolferMailer.announcement(golfer, subject, body, trip).deliver_now
        sleep(0.6)
      end

      admin_ids_on_trip = trip.golfers.where(role: :admin).pluck(:id)
      Golfer.where(role: :admin).where.not(id: admin_ids_on_trip).each do |admin|
        GolferMailer.announcement(admin, subject, body, trip).deliver_now
        sleep(0.6)
      end

      flash[:notice] = "Email sent to all golfers on KPC #{trip.number}!"
    end

    redirect_to "/dashboard"
  end
end
