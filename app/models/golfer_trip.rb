class GolferTrip < ApplicationRecord
  belongs_to :golfer
  belongs_to :trip
  has_many :nights, through: :trip
end
