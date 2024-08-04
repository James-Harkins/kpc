class GolferTripFacade
  def self.create_new_golfer_trip(golfer, trip, params)
    golfer_trip = GolferTrip.new(golfer: golfer, trip: trip)

    if params[:full_trip]
      trip.nights.each {|night| golfer.golfer_nights.create!(night_id: night.id)}
      trip.rounds.each {|round| golfer.golfer_rounds.create!(round_id: round.id)}
    else 
      params[:nights].each {|night| golfer.golfer_nights.create!(night_id: night)}
      params[:rounds].each {|round| golfer.golfer_rounds.create!(round_id: round)}
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
