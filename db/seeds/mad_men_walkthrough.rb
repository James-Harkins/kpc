# Blank-trip walkthrough scenario: KPC XXVII with a house, beds, 4 admins and a
# 25-golfer roster, nobody registered, registration closed.
#
#   bin/rails runner db/seeds/mad_men_walkthrough.rb
#
# WIPES the development database first. Needs CURRENT_TRIP_NUMBER=XXVII and
# SITE_ADMIN_EMAIL=don@sterlingcooper.com in config/application.yml.
abort "Development only." unless Rails.env.development?

PASSWORD = "oldfashioned".freeze

tables = ActiveRecord::Base.connection.tables - %w[schema_migrations ar_internal_metadata]
ActiveRecord::Base.connection.execute(
  "TRUNCATE TABLE #{tables.map { |t| ActiveRecord::Base.connection.quote_table_name(t) }.join(', ')} RESTART IDENTITY CASCADE"
)

def golfer!(first, last, nickname, email, role: :default)
  Golfer.create!(first_name: first, last_name: last, nickname: nickname, email: "#{email}@sterlingcooper.com",
                 password: PASSWORD, password_confirmation: PASSWORD, role: role, t_shirt_size: :l)
end

admins = [
  ["Don",   "Draper",   "don"],
  ["Roger", "Sterling", "roger"],
  ["Burt",  "Cooper",   "burt"],
  ["Lane",  "Pryce",    "lane"]
].map { |first, last, key| golfer!(first, last, first, key, role: :admin) }

roster = [
  ["Pete", "Campbell"], ["Ken", "Cosgrove"], ["Harry", "Crane"], ["Paul", "Kinsey"],
  ["Henry", "Francis"], ["Sal", "Romano"], ["Freddy", "Rumsen"], ["Duck", "Phillips"],
  ["Ted", "Chaough"], ["Jim", "Cutler"], ["Bob", "Benson"], ["Stan", "Rizzo"],
  ["Michael", "Ginsberg"], ["Greg", "Harris"], ["Abe", "Drummond"], ["Lee", "Garner Jr."],
  ["Jimmy", "Barrett"], ["Lou", "Avery"], ["Bobby", "Draper"], ["Arnold", "Rosen"],
  ["Kurt", "Kurtzman"], ["Joey", "Baird"], ["Ed", "Baxter"], ["Smitty", "Smith"],
  ["Gene", "Hofstadt"]
].map { |first, last| golfer!(first, last, first, first.downcase) }

trip = Trip.create!(year: 2027, number: "XXVII", location: "Virginia Beach", start_date: Date.new(2027, 4, 24),
                    deposit_due_date: Date.new(2027, 1, 1), registration_open: false)

(0..6).each { |i| trip.nights.create!(date: Date.new(2027, 4, 24) + i, cost: 130) }
[[25, 0, false], [26, 0, false], [27, 80, false], [28, 80, true], [29, 80, true], [30, 80, true]].each do |day, cost, tournament|
  trip.rounds.create!(date: Date.new(2027, 4, day), cost: cost, is_tournament_round: tournament)
end

house = trip.houses.create!(name: "Main House", address: "1 Ocean Drive, Virginia Beach", url: "https://example.com/main-house")
[
  ["Primary Suite", [["King", 2, 1]]],
  ["Ocean Queen",   [["Queen", 1, 2]]],
  ["Garden Queen",  [["Queen", 1, 3]]],
  ["Twin Room",     [["Twin A", 1, 4], ["Twin B", 1, 5]]],
  ["Bunk Room",     [["Bunk Top", 1, 6], ["Bunk Bottom", 1, 7]]],
  ["Den",           [["Shared Queen", 2, 8]]],
  ["Loft",          [["Sofa Bed", 2, 9], ["Air Mattress", 1, 10]]]
].each do |room_name, beds|
  room = house.bedrooms.create!(name: room_name)
  beds.each { |description, capacity, rank| room.beds.create!(description: description, capacity: capacity, rank: rank) }
end

puts "Seeded KPC #{trip.number}: #{admins.size} admins, #{roster.size} golfers, #{trip.nights.count} nights, " \
     "#{trip.rounds.count} rounds, #{trip.total_bed_spots} bed spots. Nobody registered; registration closed."
puts "Password for everyone: #{PASSWORD}"
