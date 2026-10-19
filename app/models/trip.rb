class Trip < ApplicationRecord
  has_many :nights
  has_many :rounds
  has_many :golfer_trips
  has_many :golfers, through: :golfer_trips
  has_many :expenses
  has_one :trip_financial_summary
  has_many :tournament_assignments
  has_many :tournament_matchup_results, through: :rounds
  has_many :houses, dependent: :destroy
  has_many :bedrooms, through: :houses
  has_many :beds, through: :bedrooms
  has_many :bed_alert_opt_outs, dependent: :destroy

  belongs_to :captain_a, class_name: 'Golfer', optional: true, foreign_key: 'captain_a_id'
  belongs_to :captain_b, class_name: 'Golfer', optional: true, foreign_key: 'captain_b_id'

  validates :year, presence: true
  validates :number, presence: true
  validates :location, presence: true
  validates :start_date, presence: true
  validate :captains_must_be_different

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

  # Suggested bed-assignment priority. Tier 1: deposit met by deposit_due_date;
  # Tier 2: met after the deadline; Tier 3: not met. Within a tier:
  # nights attending desc, then deposit_met_at asc, then registration asc.
  def bed_priority_order
    golfer_trips.includes(:golfer, :payments).sort_by do |golfer_trip|
      [golfer_trip.bed_priority_tier,
       -golfer_trip.nights_attending,
       golfer_trip.deposit_met_at || golfer_trip.created_at,
       golfer_trip.created_at]
    end
  end

  # Bed spots are counted per night, not per golfer: a golfer who leaves early
  # and one who arrives later never share a night, so together they use a
  # single spot. Total spots = sum of bed capacities across the trip's houses.
  def total_bed_spots
    beds.sum(:capacity)
  end

  # A golfer marked reserved_all_week holds their spot every night, attending or
  # not; everyone else holds one only on the nights they attend.
  def open_bed_spots_by_night
    total          = total_bed_spots
    reserved       = golfer_trips.where(reserved_all_week: true)
    reserved_count = reserved.count
    counts = GolferNight.where(night_id: nights.select(:id))
                        .where.not(golfer_id: reserved.select(:golfer_id))
                        .group(:night_id).count
    nights.order(:date).map { |night| [night, [total - reserved_count - counts.fetch(night.id, 0), 0].max] }
  end

  # Spots a new golfer could still take on at least one night. 0 means every
  # night is full ("true zero").
  def open_bed_spots
    open_bed_spots_by_night.map(&:last).max || 0
  end

  # Golfers who haven't registered for this trip and haven't opted out of
  # bed-availability emails.
  def bed_alert_recipients
    Golfer.where.not(id: golfer_trips.select(:golfer_id))
          .where.not(id: bed_alert_opt_outs.select(:golfer_id))
  end

  BED_ALERT_COOLDOWN = 1.hour

  # Called after a signup. Emails the unregistered, non-opted-out golfers the
  # new bed count at most once per BED_ALERT_COOLDOWN (keeps us under Resend's
  # daily send cap; the next blast carries the latest count). Skipped for admin
  # signups, which are bookkeeping. When a signup takes the trip from open beds
  # to none, the admins are emailed and the golfer blast ignores the cooldown.
  def send_bed_alerts(signed_up_golfer, had_open_spots)
    return if total_bed_spots.zero?

    reached_zero = had_open_spots && open_bed_spots.zero?
    BulkMailJob.perform_later('bed_capacity_reached', Golfer.admin.ids, self) if reached_zero
    return if signed_up_golfer.admin?

    if claim_bed_alert_slot(force: reached_zero)
      BulkMailJob.perform_later('bed_availability', bed_alert_recipients.ids, self)
    end
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

  private

  # Atomically stamps last_bed_alert_at; true only for the caller that won the slot.
  def claim_bed_alert_slot(force: false)
    scope = Trip.where(id: id)
    unless force
      scope = scope.where('last_bed_alert_at IS NULL OR last_bed_alert_at <= ?', BED_ALERT_COOLDOWN.ago)
    end
    scope.update_all(last_bed_alert_at: Time.current) == 1
  end

  def captains_must_be_different
    return unless captain_a_id.present? && captain_b_id.present?
    errors.add(:base, "Team captains must be different golfers") if captain_a_id == captain_b_id
  end
end
