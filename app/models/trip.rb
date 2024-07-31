class Trip < ApplicationRecord
  has_many :nights
  has_many :rounds
  has_many :golfer_trips
  has_many :golfers, through: :golfer_trips
end
