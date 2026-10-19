# Quietly registers the named golfers for the whole trip, so you can fast-forward
# toward capacity without clicking through every signup. Sends NO emails and
# triggers no bed-availability blast.
#
#   NAMES=freddy,duck,ted bin/rails runner db/seeds/mad_men_fill.rb
abort "Not in production." if Rails.env.production?

trip = Trip.current or abort "No current trip. Set CURRENT_TRIP_NUMBER."
names = ENV.fetch("NAMES").split(",").map(&:strip).reject(&:empty?)

names.each do |name|
  golfer = Golfer.find_by!(email: "#{name}@sterlingcooper.com")
  next puts("#{name}: already registered") if golfer.golfer_trips.exists?(trip_id: trip.id)

  trip.nights.each { |night| golfer.golfer_nights.find_or_create_by!(night_id: night.id) }
  trip.rounds.each { |round| golfer.golfer_rounds.find_or_create_by!(round_id: round.id) }
  golfer_trip = golfer.golfer_trips.create!(trip: trip, is_full_trip: true, deposit_policy_acknowledged_at: Time.current)
  cost = golfer.trip_net_total_cost(trip.id)
  golfer_trip.update!(cost: cost, balance: cost)
end

puts "Registered #{names.size} golfers. Open all week: #{trip.open_bed_spots} of #{trip.total_bed_spots}. Open by night: #{trip.open_bed_spots_by_night.map(&:last).join(', ')}"
