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

  def sort_by_calendar_admin
    calendar = []
    nights.each do |night|
      calendar_date = Hash.new
      calendar_date[:date] = night.date.strftime('%A %B %d, %Y') 
      calendar_date[:house_attendance] = night.golfer_nights.length
      calendar_date[:house_attendance_list] = night.golfer_nights.map {|golfer_night| golfer_night.golfer.nickname.strip.titleize}
      
      rounds.where(date: night.date).each do |round|
        calendar_date[:round_attendance] = round.golfer_rounds.length
        calendar_date[:round_attendance_list] = round.golfer_rounds.map {|golfer_round| golfer_round.golfer.nickname.strip.titleize}
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
    revenue = 0
    golfer_trips.each {|golfer_trip| revenue += golfer_trip.payments.sum(:amount)}
    revenue
  end

  def total_uncollected_revenue
    golfer_trips.sum(:balance)
  end
end
