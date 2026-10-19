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

  def deposit_final_call(golfer, golfer_trip)
    @golfer            = golfer
    @golfer_trip       = golfer_trip
    @trip              = golfer_trip.trip
    @deposit_amount    = golfer_trip.deposit_amount
    @paid_so_far       = golfer_trip.payments.sum(:amount)
    @deposit_remaining = [@deposit_amount - @paid_so_far, 0].max
    @due_date          = @trip.deposit_due_date
    mail(to: golfer.email, subject: "KPC #{@trip.number} - Deposit Due TODAY")
  end

  def balance_final_notice(golfer, golfer_trip)
    @golfer      = golfer
    @golfer_trip = golfer_trip
    @trip        = golfer_trip.trip
    @nights      = golfer.nights.where(trip_id: @trip.id).order(:date)
    @rounds      = golfer.rounds.where(trip_id: @trip.id).order(:date)
    mail(to: golfer.email, subject: "KPC #{@trip.number} - One Week Out (Balance Due)")
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

  def bed_availability(golfer, trip)
    @golfer        = golfer
    @trip          = trip
    @open_spots    = trip.open_bed_spots
    @open_by_night = trip.open_bed_spots_by_night
    @register_url  = register_trip_url
    @opt_out_url   = bed_alert_opt_out_url(token: BedAlertOptOut.token_for(golfer, trip))
    subject = if @open_spots.zero?
      "KPC #{trip.number} - The House Is Full"
    else
      "KPC #{trip.number} - #{@open_spots} #{'Bed'.pluralize(@open_spots)} Left"
    end
    mail(to: golfer.email, subject: subject)
  end

  def bed_capacity_reached(admin, trip)
    @admin            = admin
    @trip             = trip
    @registered_count = trip.golfer_trips.count
    @recipient_count  = trip.bed_alert_recipients.count
    @bed_assignments_url = bed_assignments_url(trip_id: trip.id)
    mail(to: admin.email, subject: "KPC #{trip.number} - Bed Capacity Hit 0")
  end
end
