class Trip < ApplicationRecord
  has_many :nights
  has_many :rounds
  has_many :golfer_trips
  has_many :golfers, through: :golfer_trips
  has_many :expenses
  has_one :trip_financial_summary

  validates :year, presence: true
  validates :number, presence: true
  validates :location, presence: true
  validates :start_date, presence: true

  def self.current
    where(number: ENV['CURRENT_TRIP_NUMBER']).first
  end

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

  def total_expenses
    expenses.sum(:amount)
  end

  def balance
    total_projected_revenue - total_expenses
  end

  def total_man_nights
    man_nights = 0
    nights.each {|night| man_nights += night.golfer_nights.length}
    man_nights - number_of_full_trips
  end

  def number_of_full_trips
    golfer_trips.where(is_full_trip: true).count
  end

  def admin_net_deficit
    total_expenses - total_projected_revenue
  end

  def admin_cost_breakdown
    admin_golfers = Golfer.where(role: :admin).order(:last_name, :first_name)
    count = admin_golfers.count
    return [] if count == 0

    share = admin_net_deficit.to_f / count
    treasurer_email = ENV['TREASURER_EMAIL']

    admin_golfers.map do |g|
      expenses_paid = expenses.where(golfer_id: g.id).sum(:amount)
      is_treasurer  = treasurer_email.present? && g.email == treasurer_email
      adjusted_paid = is_treasurer ? expenses_paid - total_projected_revenue : expenses_paid

      entry = {
        golfer:       g,
        paid:         adjusted_paid,
        fair_share:   share,
        balance:      adjusted_paid - share,
        is_treasurer: is_treasurer
      }
      if is_treasurer
        entry[:expenses_paid]       = expenses_paid
        entry[:revenue_collected]   = total_projected_revenue
      end
      entry
    end
  end

  def admin_settlements
    breakdown = admin_cost_breakdown
    creditors = breakdown.select { |b| b[:balance] > 0.5 }
                         .map { |b| { golfer: b[:golfer], amount: b[:balance].round } }
                         .sort_by { |b| -b[:amount] }
    debtors   = breakdown.select { |b| b[:balance] < -0.5 }
                         .map { |b| { golfer: b[:golfer], amount: (-b[:balance]).round } }
                         .sort_by { |b| -b[:amount] }

    settlements = []
    ci, di = 0, 0

    while ci < creditors.length && di < debtors.length
      amount = [creditors[ci][:amount], debtors[di][:amount]].min
      settlements << { payer: debtors[di][:golfer], payee: creditors[ci][:golfer], amount: amount }
      creditors[ci][:amount] -= amount
      debtors[di][:amount]   -= amount
      ci += 1 if creditors[ci][:amount] < 1
      di += 1 if debtors[di][:amount] < 1
    end

    settlements
  end
end
