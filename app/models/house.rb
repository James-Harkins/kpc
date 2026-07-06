class House < ApplicationRecord
  belongs_to :trip
  has_many :bedrooms, dependent: :destroy
  has_many :beds, through: :bedrooms

  validates :name, presence: true
end
