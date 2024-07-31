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

#   def trip_meals_total_cost(trip_id)
#     meals.where(trip_id: trip_id).sum(:cost)
#   end

#   def trip_nights_total_cost(trip_id)
#     nights.where(trip_id: trip_id).sum(:cost)
#   end

#   def trip_courses_total_cost(trip_id)
#     golfer_trip_courses.joins(:trip_course)
#     .where(trip_courses: {trip_id: trip_id})
#     .sum(:cost)
#   end

#   def trip_total_cost(trip_id)
#     trip_meals_total_cost(trip_id) +
#     trip_nights_total_cost(trip_id) +
#     trip_courses_total_cost(trip_id)
#   end
end
