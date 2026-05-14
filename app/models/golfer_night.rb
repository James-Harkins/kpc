class GolferNight < ApplicationRecord
  belongs_to :golfer
  belongs_to :night

  validates :golfer_id, uniqueness: { scope: :night_id, message: "is already signed up for this night" }
end
