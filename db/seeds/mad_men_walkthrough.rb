# Walkthrough scenario: KPC XXVII with one house of 25 bed slots, 4 admins already
# registered (reserved all week) and a 25-golfer roster nobody has registered yet.
# Registration is closed.
#
#   bin/rails runner db/seeds/mad_men_walkthrough.rb
#
# WIPES the development database first. Needs CURRENT_TRIP_NUMBER=XXVII and
# SITE_ADMIN_EMAIL=don@sterlingcooper.com in config/application.yml.
abort "Development only." unless Rails.env.development? || ENV["WALKTHROUGH_SEED_ALLOW"] == "1"

PASSWORD = "oldfashioned".freeze

tables = ActiveRecord::Base.connection.tables - %w[schema_migrations ar_internal_metadata]
ActiveRecord::Base.connection.execute(
  "TRUNCATE TABLE #{tables.map { |t| ActiveRecord::Base.connection.quote_table_name(t) }.join(', ')} RESTART IDENTITY CASCADE"
)

def golfer!(first, last, email, role: :default)
  Golfer.create!(first_name: first, last_name: last, nickname: first, email: "#{email}@sterlingcooper.com",
                 password: PASSWORD, password_confirmation: PASSWORD, role: role, t_shirt_size: :l)
end

admins = {
  "don"   => golfer!("Don",   "Draper",   "don",   role: :admin),
  "roger" => golfer!("Roger", "Sterling", "roger", role: :admin),
  "burt"  => golfer!("Burt",  "Cooper",   "burt",  role: :admin),
  "lane"  => golfer!("Lane",  "Pryce",    "lane",  role: :admin)
}

roster = [
  ["Pete", "Campbell"], ["Ken", "Cosgrove"], ["Harry", "Crane"], ["Paul", "Kinsey"],
  ["Henry", "Francis"], ["Sal", "Romano"], ["Freddy", "Rumsen"], ["Duck", "Phillips"],
  ["Ted", "Chaough"], ["Jim", "Cutler"], ["Bob", "Benson"], ["Stan", "Rizzo"],
  ["Michael", "Ginsberg"], ["Greg", "Harris"], ["Abe", "Drummond"], ["Lee", "Garner Jr."],
  ["Jimmy", "Barrett"], ["Lou", "Avery"], ["Bobby", "Draper"], ["Arnold", "Rosen"],
  ["Kurt", "Kurtzman"], ["Joey", "Baird"], ["Ed", "Baxter"], ["Smitty", "Smith"],
  ["Gene", "Hofstadt"]
].map { |first, last| golfer!(first, last, first.downcase) }

trip = Trip.create!(year: 2027, number: "XXVII", location: "Virginia Beach", start_date: Date.new(2027, 4, 24),
                    deposit_due_date: Date.new(2027, 1, 1), registration_open: false)

(0..6).each { |i| trip.nights.create!(date: Date.new(2027, 4, 24) + i, cost: 130) }
[[25, 0, false], [26, 0, false], [27, 80, false], [28, 80, true], [29, 80, true], [30, 80, true]].each do |day, cost, tournament|
  trip.rounds.create!(date: Date.new(2027, 4, day), cost: cost, is_tournament_round: tournament)
end

# One house, 25 bed slots (a slot is one sleeper, so a capacity-2 bed is two slots).
house = trip.houses.create!(name: "Main House", address: "1 Ocean Drive, Virginia Beach", url: "https://example.com/main-house")
[
  ["Primary Suite", [["King", 2]]],
  ["Ocean Suite",   [["King", 2]]],
  ["Garden Room",   [["Queen", 1]]],
  ["Sunroom",       [["Queen", 1]]],
  ["Den",           [["Shared Queen", 2]]],
  ["Twin Room A",   [["Twin A", 1], ["Twin B", 1]]],
  ["Twin Room B",   [["Twin C", 1], ["Twin D", 1]]],
  ["Bunk Room",     [["Bunk 1 Top", 1], ["Bunk 1 Bottom", 1], ["Bunk 2 Top", 1], ["Bunk 2 Bottom", 1]]],
  ["Loft",          [["Sofa Bed", 2], ["Daybed", 1], ["Air Mattress", 1], ["Air Mattress 2", 1]]],
  ["Basement",      [["Pullout Couch", 2], ["Futon", 2]]]
].each do |room_name, beds|
  room = house.bedrooms.create!(name: room_name)
  beds.each { |description, capacity| room.beds.create!(description: description, capacity: capacity, rank: (Bed.maximum(:rank) || 0) + 1) }
end

# Admins are already registered: no cost, bed reserved all week. Don is Mon-Fri, the rest attend every night.
nights = trip.nights.order(:date).to_a
rounds = trip.rounds.order(:date).to_a
{ "don" => nights[2..6], "roger" => nights, "burt" => nights, "lane" => nights }.each do |key, stay|
  admin = admins.fetch(key)
  stay.each { |night| admin.golfer_nights.create!(night: night) }
  rounds.select { |round| stay.map(&:date).include?(round.date) }.each { |round| admin.golfer_rounds.create!(round: round) }
  admin.golfer_trips.create!(trip: trip, is_full_trip: stay.length == nights.length, cost: 0, balance: 0,
                             is_paid: true, reserved_all_week: true)
end

puts "Seeded KPC #{trip.number}: #{admins.size} admins (registered), #{roster.size} golfers (not registered), " \
     "#{trip.nights.count} nights, #{trip.rounds.count} rounds, #{trip.total_bed_spots} bed slots, " \
     "#{trip.open_bed_spots} open all week. Registration closed."
puts "Password for everyone: #{PASSWORD}"
