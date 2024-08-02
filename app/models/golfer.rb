class Golfer < ApplicationRecord
  has_many :golfer_trips
  has_many :trips, through: :golfer_trips
  has_many :golfer_nights
  has_many :nights, through: :golfer_nights
  has_many :golfer_rounds
  has_many :rounds, through: :golfer_rounds

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates :email, uniqueness: true
  validates_presence_of :password
  validates_presence_of :password_confirmation
  has_secure_password
  enum role: [:default, :admin]

  def trip_nights_total_cost(trip_id)
    nights.where(trip_id: trip_id).sum(:cost)
  end

  def trip_rounds_total_cost(trip_id)
    rounds.where(trip_id: trip_id)
    .sum(:cost)
  end

  def trip_net_total_cost(trip_id)
    golfer_trip = golfer_trips.where(trip_id: trip_id).first
    if golfer_trip.is_full_trip
      trip_gross_total_cost(trip_id) - 
      trip_first_night_cost(golfer_trip)
    else 
      trip_gross_total_cost(trip_id)
    end
  end

  def trip_gross_total_cost(trip_id)
    trip_nights_total_cost(trip_id) +
    trip_rounds_total_cost(trip_id)
  end

  def trip_first_night_cost(golfer_trip)
    golfer_trip.trip.nights.first.cost
  end
end
