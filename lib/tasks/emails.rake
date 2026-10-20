namespace :emails do
  desc "Send pre-trip reminders (1 month out: everyone; 1 week out: unpaid balances only)"
  task send_pre_trip_reminder: :environment do
    dry_run = ENV["DRY_RUN"] == "true"
    trip    = Trip.current

    abort "No current trip found. Set CURRENT_TRIP_NUMBER env var." if trip.nil?
    abort "Trip has no start_date set." if trip.start_date.nil?

    one_month_date = trip.start_date.to_date - 1.month
    one_week_date  = trip.start_date.to_date - 7.days

    mode =
      if dry_run
        ENV["FINAL_NOTICE"] == "true" ? :final_notice : :one_month
      elsif Date.today == one_month_date
        :one_month
      elsif Date.today == one_week_date
        :final_notice
      else
        puts "Today (#{Date.today}) is neither one month (#{one_month_date}) nor one week (#{one_week_date}) before the trip start date. No emails sent."
        exit
      end

    if mode == :one_month
      puts "#{"[DRY RUN] " if dry_run}Sending one-month reminders for KPC #{trip.number}..."

      trip.golfer_trips.includes(:golfer).each do |golfer_trip|
        golfer = golfer_trip.golfer
        if golfer_trip.balance == 0
          GolferMailer.trip_reminder_paid(golfer, golfer_trip).deliver_now unless dry_run
          puts "  #{"[DRY RUN] Would send" if dry_run}#{"Sent" unless dry_run} paid reminder to #{golfer.nickname}"
        else
          GolferMailer.trip_reminder_unpaid(golfer, golfer_trip).deliver_now unless dry_run
          puts "  #{"[DRY RUN] Would send" if dry_run}#{"Sent" unless dry_run} unpaid reminder to #{golfer.nickname} (balance: $#{golfer_trip.balance})"
        end
        sleep(0.6) unless dry_run
      end

      puts "#{"[DRY RUN] " if dry_run}Done! #{dry_run ? "Would have sent" : "Sent"} reminders to #{trip.golfer_trips.count} golfers."
    else
      puts "#{"[DRY RUN] " if dry_run}Sending one-week balance final notices for KPC #{trip.number}..."

      sent = 0
      trip.golfer_trips.includes(:golfer).each do |golfer_trip|
        golfer = golfer_trip.golfer
        next if golfer_trip.balance == 0
        GolferMailer.balance_final_notice(golfer, golfer_trip).deliver_now unless dry_run
        puts "  #{"[DRY RUN] Would send" if dry_run}#{"Sent" unless dry_run} final notice to #{golfer.nickname} (balance: $#{golfer_trip.balance})"
        sent += 1
        sleep(0.6) unless dry_run
      end

      puts "#{"[DRY RUN] " if dry_run}Done! #{dry_run ? "Would have sent" : "Sent"} final notices to #{sent} golfers."
    end
  end

  desc "Send deposit reminders (1 week before deadline) and final calls (deadline day) to golfers who haven't met their 50% deposit"
  task send_deposit_reminder: :environment do
    dry_run = ENV["DRY_RUN"] == "true"
    trip    = Trip.current

    abort "No current trip found. Set CURRENT_TRIP_NUMBER env var." if trip.nil?
    abort "Trip has no deposit_due_date set." if trip.deposit_due_date.nil?

    reminder_date   = trip.deposit_due_date - 7.days
    final_call_date = trip.deposit_due_date

    mode =
      if dry_run
        ENV["FINAL_CALL"] == "true" ? :final_call : :reminder
      elsif Date.today == reminder_date
        :reminder
      elsif Date.today == final_call_date
        :final_call
      else
        puts "Today (#{Date.today}) is neither one week before the deposit deadline (#{reminder_date}) nor the deadline itself (#{final_call_date}). No emails sent."
        exit
      end

    label = mode == :final_call ? "deposit final call" : "deposit reminder"
    puts "#{"[DRY RUN] " if dry_run}Sending #{label}s for KPC #{trip.number} (deadline: #{trip.deposit_due_date})..."

    sent = 0
    trip.golfer_trips.includes(:golfer, :payments).each do |golfer_trip|
      golfer = golfer_trip.golfer
      next if golfer.admin?
      if golfer_trip.deposit_met?
        puts "  Skipping #{golfer.nickname} (deposit already met)"
        next
      end
      if mode == :final_call
        GolferMailer.deposit_final_call(golfer, golfer_trip).deliver_now unless dry_run
      else
        GolferMailer.deposit_reminder(golfer, golfer_trip).deliver_now unless dry_run
      end
      puts "  #{"[DRY RUN] Would send" if dry_run}#{"Sent" unless dry_run} #{label} to #{golfer.nickname} ($#{golfer_trip.payments.sum(:amount)} of $#{golfer_trip.deposit_amount} paid)"
      sent += 1
      sleep(0.6) unless dry_run
    end

    puts "#{"[DRY RUN] " if dry_run}Done! #{dry_run ? "Would have sent" : "Sent"} #{label}s to #{sent} golfers."
  end

  desc "Send the weekly bed-availability email to unregistered, non-admin golfers who haven't opted out"
  task send_bed_availability: :environment do
    dry_run = ENV["DRY_RUN"] == "true"
    trip    = Trip.current

    abort "No current trip found. Set CURRENT_TRIP_NUMBER env var." if trip.nil?

    if trip.completed? || (trip.start_date.present? && trip.start_date <= Time.current) || !trip.registration_open? || trip.total_bed_spots.zero? || trip.open_bed_spots_any_night.zero?
      puts "KPC #{trip.number} is completed, already started, closed to registration, has no beds entered, or is full. No emails sent."
      exit
    end

    puts "#{"[DRY RUN] " if dry_run}Sending bed availability for KPC #{trip.number}..."

    sent = 0
    trip.bed_alert_recipients.each do |golfer|
      GolferMailer.bed_availability(golfer, trip).deliver_now unless dry_run
      puts "  #{"[DRY RUN] Would send" if dry_run}#{"Sent" unless dry_run} to #{golfer.nickname}"
      sent += 1
      sleep(0.6) unless dry_run
    end

    puts "#{"[DRY RUN] " if dry_run}Done! #{dry_run ? "Would have sent" : "Sent"} bed availability to #{sent} golfers."
  end
end
