class GolferTrip < ApplicationRecord
  belongs_to :golfer
  belongs_to :trip
  has_many :nights, through: :trip
  has_many :payments, dependent: :destroy

  validates :golfer_id, uniqueness: { scope: :trip_id, message: "is already signed up for this trip" }
end
