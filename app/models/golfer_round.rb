class GolferRound < ApplicationRecord
  belongs_to :golfer
  belongs_to :round
end
