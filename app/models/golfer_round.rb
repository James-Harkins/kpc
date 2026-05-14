class GolferRound < ApplicationRecord
  belongs_to :golfer
  belongs_to :round

  validates :golfer_id, uniqueness: { scope: :round_id, message: "is already signed up for this round" }
end
