class Bedroom < ApplicationRecord
  belongs_to :house
  has_many :beds, dependent: :destroy

  validates :name, presence: true
end
