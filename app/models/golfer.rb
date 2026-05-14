class Golfer < ApplicationRecord
  has_many :golfer_trips
  has_many :trips, through: :golfer_trips
  has_many :golfer_nights
  has_many :nights, through: :golfer_nights
  has_many :golfer_rounds
  has_many :rounds, through: :golfer_rounds

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :nickname
  validates_presence_of :email
  validates :email, uniqueness: true
  validates_presence_of :password, on: :create
  validates_presence_of :password_confirmation, on: :create
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  has_secure_password
  validates_presence_of :t_shirt_size, on: :create
  enum role: [:default, :admin]
  enum t_shirt_size: { s: 0, m: 1, l: 2, xl: 3, xxl: 4, xxxl: 5 }

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

  def is_registered_for_next_trip(next_trip)
    registered = false
    
    trips.each do |trip|
      if trip.id == next_trip.id
        registered = true
      end
    end
    
    registered
  end

  def self.night_admin_count(date)
    if Date.parse(date) != Date.parse('2026-04-18') && Date.parse(date) != Date.parse('2026-04-19')
      where(role: :admin).count
    else 
      where(role: :admin).count - 1
    end
  end

  def self.round_admin_count(date)
    if Date.parse(date) != Date.parse('2026-04-18') && Date.parse(date) != Date.parse('2026-04-19') && Date.parse(date) != Date.parse('2026-04-20')
      where(role: :admin).count
    else 
      where(role: :admin).count - 1
    end
  end

  def trip_night_calendar(trip_id)
    nights.where(trip_id: trip_id).map {|night| night.date.strftime('%A')}
  end

  def trip_round_calendar(trip_id)
    rounds.where(trip_id: trip_id).map {|round| round.date.strftime('%A')}
  end

  def registered_full_trip(trip_id)
    trip_night_calendar(trip_id).length == 7 &&
    trip_round_calendar(trip_id).length == 6
  end

  def generate_password_reset_token!
    raw_token = SecureRandom.urlsafe_base64
    update_columns(
      password_reset_token: Digest::SHA256.hexdigest(raw_token),
      password_reset_sent_at: Time.zone.now
    )
    raw_token
  end

  def password_reset_expired?
    password_reset_sent_at < 2.hours.ago
  end
end
