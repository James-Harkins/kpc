class Night < ApplicationRecord
  belongs_to :trip
  has_many :golfer_nights
  has_many :golfers, through: :golfer_nights
end
