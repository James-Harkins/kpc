class Course < ApplicationRecord
  has_many :rounds
  validates :name, presence: true
end
