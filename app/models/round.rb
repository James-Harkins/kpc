class Round < ApplicationRecord
  belongs_to :trip
  belongs_to :course, optional: true
  has_many :golfer_rounds
  has_many :golfers, through: :golfer_rounds
end
