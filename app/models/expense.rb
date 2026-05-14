class Expense < ApplicationRecord
  belongs_to :trip
  belongs_to :golfer

  validates :amount, presence: true, numericality: { only_integer: true, other_than: 0 }
  validates :description, presence: true

  before_validation :set_default_date

  private

  def set_default_date
    self.date ||= Date.today
  end
end
