class GolferTrip < ApplicationRecord
  belongs_to :golfer
  belongs_to :trip
  belongs_to :bed, optional: true
  has_many :nights, through: :trip
  has_many :payments, dependent: :destroy

  validates :golfer_id, uniqueness: { scope: :trip_id, message: "is already signed up for this trip" }
  validate :bed_capacity_not_exceeded, if: -> { bed_id.present? && will_save_change_to_bed_id? }
  validate :bed_belongs_to_same_trip,  if: -> { bed_id.present? && will_save_change_to_bed_id? }

  def deposit_amount
    (cost.to_i / 2.0).ceil
  end

  # Timestamp of the payment whose running total last crossed the 50% deposit,
  # or nil if the current net total no longer meets it (a later return
  # un-meets the deposit — an early timestamp can't be banked and refunded).
  def deposit_met_at
    return created_at if deposit_amount.zero?
    ordered = payments.order(:created_at, :id).to_a
    return nil if ordered.sum(&:amount) < deposit_amount

    running = 0
    met_at = nil
    ordered.each do |payment|
      was_below = running < deposit_amount
      running += payment.amount
      met_at = payment.created_at if was_below && running >= deposit_amount
    end
    met_at
  end

  def deposit_met?
    deposit_met_at.present?
  end

  def deposit_met_by_deadline?
    met_at = deposit_met_at
    return false if met_at.nil?
    return true if trip.deposit_due_date.nil?
    met_at.to_date <= trip.deposit_due_date
  end

  def bed_priority_tier
    return 3 unless deposit_met?
    deposit_met_by_deadline? ? 1 : 2
  end

  def nights_attending
    golfer.nights.where(trip_id: trip_id).count
  end

  private

  def bed_capacity_not_exceeded
    other_occupants = GolferTrip.where(bed_id: bed_id).where.not(id: id).count
    errors.add(:bed, "is already at capacity") if other_occupants >= bed.capacity
  end

  def bed_belongs_to_same_trip
    errors.add(:bed, "belongs to a different trip") unless bed.trip.id == trip_id
  end
end
