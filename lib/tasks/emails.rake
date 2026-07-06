namespace :emails do
  desc "Send pre-trip reminder emails to all golfers one month before start date"
  task send_pre_trip_reminder: :environment do
    dry_run = ENV["DRY_RUN"] == "true"
    trip    = Trip.current

    abort "No current trip found. Set CURRENT_TRIP_NUMBER env var." if trip.nil?
    abort "Trip has no start_date set." if trip.start_date.nil?

    send_date = trip.start_date.to_date - 1.month
    unless dry_run || Date.today == send_date
      puts "Today (#{Date.today}) is not one month before the trip start date (#{send_date}). No emails sent."
      exit
    end

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
  end

  desc "Send deposit reminder emails to golfers who haven't met their 50% deposit, one week before the deadline"
  task send_deposit_reminder: :environment do
    dry_run = ENV["DRY_RUN"] == "true"
    trip    = Trip.current

    abort "No current trip found. Set CURRENT_TRIP_NUMBER env var." if trip.nil?
    abort "Trip has no deposit_due_date set." if trip.deposit_due_date.nil?

    send_date = trip.deposit_due_date - 7.days
    unless dry_run || Date.today == send_date
      puts "Today (#{Date.today}) is not one week before the deposit deadline (#{send_date}). No emails sent."
      exit
    end

    puts "#{"[DRY RUN] " if dry_run}Sending deposit reminders for KPC #{trip.number} (deadline: #{trip.deposit_due_date})..."

    sent = 0
    trip.golfer_trips.includes(:golfer, :payments).each do |golfer_trip|
      golfer = golfer_trip.golfer
      next if golfer.admin?
      if golfer_trip.deposit_met?
        puts "  Skipping #{golfer.nickname} (deposit already met)"
        next
      end
      GolferMailer.deposit_reminder(golfer, golfer_trip).deliver_now unless dry_run
      puts "  #{"[DRY RUN] Would send" if dry_run}#{"Sent" unless dry_run} deposit reminder to #{golfer.nickname} ($#{golfer_trip.payments.sum(:amount)} of $#{golfer_trip.deposit_amount} paid)"
      sent += 1
      sleep(0.6) unless dry_run
    end

    puts "#{"[DRY RUN] " if dry_run}Done! #{dry_run ? "Would have sent" : "Sent"} deposit reminders to #{sent} golfers."
  end
end
