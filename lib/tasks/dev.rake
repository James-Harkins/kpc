namespace :dev do
  desc "Seed historical trip attendance and financial summaries for testing the previous trips index"
  task seed_past_trips: :environment do
    admin_count       = Golfer.where(role: :admin).count
    non_admin_golfers = Golfer.where(role: :default).order(:nickname).to_a

    if non_admin_golfers.empty?
      puts "No non-admin golfers found — run db:seed first."
      next
    end

    # -------------------------------------------------------------------------
    # Trip definitions
    #   XIII–XVI already exist from db:seed (nights + rounds already seeded).
    #   XXV is created here if it doesn't exist yet.
    # -------------------------------------------------------------------------
    trip_configs = [
      { number: "XIII", year: 2013, location: "Dewey Beach, DE",      overhead: 1_000 },
      { number: "XIV",  year: 2014, location: "Rehoboth Beach, DE",   overhead: 1_200 },
      { number: "XV",   year: 2015, location: "Virginia Beach, VA",   overhead: 1_400 },
      { number: "XVI",  year: 2016, location: "Virginia Beach, VA",   overhead: 1_100 },
      { number: "XXV",  year: 2025, location: "Myrtle Beach, SC",     overhead: 1_600,
        start_date: "2025-04-20",
        nights: { "2025-04-20" => 110, "2025-04-21" => 110, "2025-04-22" => 110,
                  "2025-04-23" => 110, "2025-04-24" => 110, "2025-04-25" => 110,
                  "2025-04-26" => 110 },
        rounds: { "2025-04-21" => 0,  "2025-04-22" => 0,  "2025-04-23" => 75,
                  "2025-04-24" => 75, "2025-04-25" => 75, "2025-04-26" => 75 } },
    ]

    trip_configs.each_with_index do |config, trip_idx|
      # -- Find or create the trip ------------------------------------------
      trip = Trip.find_or_create_by!(number: config[:number]) do |t|
        t.year       = config[:year]
        t.location   = config[:location]
        t.start_date = Date.parse(config[:start_date]) if config[:start_date]
      end
      puts "\nKPC #{trip.number} — #{trip.location} (id #{trip.id})"

      # -- Seed nights and rounds for XXV (XIII–XVI already have them) -------
      if config[:nights]
        config[:nights].each do |date_str, cost|
          trip.nights.find_or_create_by!(date: Date.parse(date_str)) { |n| n.cost = cost }
        end
      end
      if config[:rounds]
        config[:rounds].each do |date_str, cost|
          trip.rounds.find_or_create_by!(date: Date.parse(date_str)) { |r| r.cost = cost }
        end
      end

      nights = trip.nights.order(:date).to_a
      rounds = trip.rounds.order(:date).to_a

      if nights.empty?
        puts "  No nights found — skipping."
        next
      end

      # -- Five attendance patterns, offset per trip for visual variety -------
      #   0 — full trip:        all nights, all rounds
      #   1 — late arrival:     nights 3–end, rounds 3–end
      #   2 — early departure:  nights 1–4, rounds 1–3
      #   3 — middle stretch:   nights 2–5, rounds 2–4
      #   4 — bookends only:    first 2 nights + last 2 nights, first + last 2 rounds
      patterns = [
        { n: nights,           r: rounds },
        { n: nights[2..],      r: rounds[2..] },
        { n: nights[0..3],     r: rounds[0..2] },
        { n: nights[1..4],     r: rounds[1..3] },
        { n: nights[0..1] + nights[-2..], r: ([rounds.first] + rounds[-2..]).compact },
      ]

      total_revenue = 0

      non_admin_golfers.each_with_index do |golfer, i|
        pattern        = patterns[(i + trip_idx) % patterns.length]
        att_nights     = Array(pattern[:n]).compact
        att_rounds     = Array(pattern[:r]).compact
        is_full        = att_nights.length == nights.length
        cost           = att_nights.sum(&:cost) + att_rounds.sum(&:cost)

        gt = GolferTrip.find_or_create_by!(golfer: golfer, trip: trip) do |g|
          g.is_full_trip = is_full
          g.cost         = cost
          g.balance      = 0
          g.is_paid      = true
        end

        att_nights.each { |n| GolferNight.find_or_create_by!(golfer: golfer, night: n) }
        att_rounds.each { |r| GolferRound.find_or_create_by!(golfer: golfer, round: r) }
        gt.payments.find_or_create_by!(amount: gt.cost) if gt.payments.none?

        total_revenue += gt.cost
        puts "  #{golfer.nickname.ljust(16)} #{att_nights.length} nights, #{att_rounds.length} rounds — $#{cost}"
      end

      # -- TripFinancialSummary ----------------------------------------------
      total_expenses = total_revenue + config[:overhead]
      deficit        = total_expenses - total_revenue

      summary = TripFinancialSummary.find_or_initialize_by(trip: trip)
      summary.update!(
        total_revenue:   total_revenue,
        total_expenses:  total_expenses,
        total_deficit:   deficit,
        fair_share:      admin_count > 0 ? (deficit.to_f / admin_count).round : 0,
        committee_count: admin_count
      )
      puts "  Summary: revenue $#{total_revenue}, expenses $#{total_expenses}, " \
           "deficit $#{deficit}, fair share $#{summary.fair_share}"
    end

    puts "\nDone."
  end
end
