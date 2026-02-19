class GolferMailer < ApplicationMailer
  def password_reset(golfer, token)
    @golfer = golfer
    @reset_url = edit_password_reset_url(token)
    mail(to: @golfer.email, subject: "KPC Password Reset")
  end

  def trip_signup(golfer, golfer_trip)
    @golfer      = golfer
    @golfer_trip = golfer_trip
    @trip        = golfer_trip.trip
    @nights      = golfer.nights.where(trip_id: @trip.id).order(:date)
    @rounds      = golfer.rounds.where(trip_id: @trip.id).order(:date)
    mail(to: golfer.email, subject: "KPC #{@trip.number} - You're In!")
  end
end
