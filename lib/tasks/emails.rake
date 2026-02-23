namespace :emails do
  desc "Send pre-trip reminder emails to all golfers one month before start date"
  task send_pre_trip_reminder: :environment do
    dry_run = ENV["DRY_RUN"] == "true"
    trip    = Trip.current

    abort "No current trip found. Set CURRENT_TRIP_NUMBER env var." if trip.nil?
    abort "Trip has no start_date set." if trip.start_date.nil?

    unless dry_run || Date.today == trip.start_date.to_date.prev_month
      puts "Today (#{Date.today}) is not one month before trip start (#{trip.start_date.to_date}). No emails sent."
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
end
