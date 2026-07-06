class GolferMailer < ApplicationMailer
  def welcome(golfer, token)
    @golfer           = golfer
    @token            = token
    @set_password_url = edit_password_reset_url(token)
    mail(to: golfer.email, subject: "Welcome to Kitchen Pass Classic")
  end

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

  def deposit_reminder(golfer, golfer_trip)
    @golfer            = golfer
    @golfer_trip       = golfer_trip
    @trip              = golfer_trip.trip
    @deposit_amount    = golfer_trip.deposit_amount
    @paid_so_far       = golfer_trip.payments.sum(:amount)
    @deposit_remaining = [@deposit_amount - @paid_so_far, 0].max
    @due_date          = @trip.deposit_due_date
    mail(to: golfer.email, subject: "KPC #{@trip.number} - Deposit Due #{@due_date.strftime('%B %-d')}")
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
