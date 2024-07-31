class Round < ApplicationRecord
  belongs_to :trip
  has_many :golfer_rounds
  has_many :golfers, through: :golfer_rounds
end
