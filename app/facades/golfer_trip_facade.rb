class GolferTripFacade
  def self.create_new_golfer_trip(golfer, trip, params)
    golfer_trip = GolferTrip.new(golfer: golfer, trip: trip)

    if params[:full_trip]
      trip.nights.each {|night| golfer.golfer_nights.create!(night_id: night.id)}
      trip.rounds.each {|round| golfer.golfer_rounds.create!(round_id: round.id)}
    else
      valid_night_ids = trip.nights.pluck(:id).map(&:to_s)
      valid_round_ids = trip.rounds.pluck(:id).map(&:to_s)
      params[:nights].select { |n| valid_night_ids.include?(n.to_s) }
                     .each   { |n| golfer.golfer_nights.create!(night_id: n) }
      params[:rounds].select { |r| valid_round_ids.include?(r.to_s) }
                     .each   { |r| golfer.golfer_rounds.create!(round_id: r) }
    end
    
    if is_full_trip(params, trip)
      golfer_trip.is_full_trip = true
    end

    golfer_trip
  end

  def self.is_full_trip(params, trip)
    params[:full_trip] || 
    ((params[:nights].length == trip.nights.length) &&
    (params[:rounds].length == trip.rounds.length))
  end
end
