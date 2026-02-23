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

  def payment_received(golfer, golfer_trip, payment)
    @golfer      = golfer
    @golfer_trip = golfer_trip
    @payment     = payment
    @trip        = golfer_trip.trip
    mail(to: golfer.email, subject: "KPC #{@trip.number} - Payment Received")
  end

  def balance_paid(golfer, golfer_trip)
    @golfer      = golfer
    @golfer_trip = golfer_trip
    @trip        = golfer_trip.trip
    mail(to: golfer.email, subject: "KPC #{@trip.number} - You're All Paid Up!")
  end

  def announcement(golfer, subject, body, trip)
    @golfer  = golfer
    @subject = subject
    @body    = body
    @trip    = trip
    mail(to: golfer.email, subject: subject)
  end

  def trip_reminder_paid(golfer, golfer_trip)
    @golfer      = golfer
    @golfer_trip = golfer_trip
    @trip        = golfer_trip.trip
    @nights      = golfer.nights.where(trip_id: @trip.id).order(:date)
    @rounds      = golfer.rounds.where(trip_id: @trip.id).order(:date)
    mail(to: golfer.email, subject: "KPC #{@trip.number} - One Month Out!")
  end

  def trip_reminder_unpaid(golfer, golfer_trip)
    @golfer      = golfer
    @golfer_trip = golfer_trip
    @trip        = golfer_trip.trip
    @nights      = golfer.nights.where(trip_id: @trip.id).order(:date)
    @rounds      = golfer.rounds.where(trip_id: @trip.id).order(:date)
    mail(to: golfer.email, subject: "KPC #{@trip.number} - One Month Out (Balance Due)")
  end
end
