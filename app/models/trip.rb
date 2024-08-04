class Trip < ApplicationRecord
  has_many :nights
  has_many :rounds
  has_many :golfer_trips
  has_many :golfers, through: :golfer_trips

  def sort_by_calendar
    calendar = []
    nights.each do |night|
      calendar_date = Hash.new
      calendar_date[:date] = night.date.strftime('%A %B %d, %Y') 
      calendar_date[:night] = {
        id: night.id,  
        cost: night.cost
      }

      calendar_date[:round] = Hash.new 
      rounds.where(date: night.date).each do |round|
        calendar_date[:round][:id] = round.id
        calendar_date[:round][:cost] = round.cost
      end
      calendar << calendar_date
    end
  
    calendar
  end

  def paid_golfer_trips
    golfer_trips.where(is_paid: true)
  end

  def unpaid_golfer_trips
    golfer_trips.where(is_paid: false)
  end
  
  def total_projected_revenue
    golfer_trips.sum(:cost)
  end

  def total_collected_revenue
    golfer_trips.where(is_paid: true).sum(:cost)
  end

  def total_uncollected_revenue
    golfer_trips.where(is_paid: false).sum(:cost)
  end
end
