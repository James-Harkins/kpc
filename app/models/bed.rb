class Bed < ApplicationRecord
  belongs_to :bedroom
  has_one :house, through: :bedroom
  has_many :golfer_trips, dependent: :nullify

  validates :capacity, inclusion: { in: [1, 2] }
  validates :rank, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :rank_unique_within_trip
  validate :capacity_covers_current_occupants

  def trip
    bedroom.house.trip
  end

  private

  def rank_unique_within_trip
    return if rank.blank? || bedroom.nil?
    clash = Bed.joins(bedroom: :house)
               .where(houses: { trip_id: bedroom.house.trip_id }, rank: rank)
               .where.not(id: id)
    errors.add(:rank, "#{rank} is already taken by another bed on this trip") if clash.exists?
  end

  def capacity_covers_current_occupants
    return if new_record? || capacity.nil?
    peak = GolferTrip.peak_night_load(golfer_trips)
    errors.add(:capacity, "cannot be less than current occupants (#{peak})") if capacity < peak
  end
end
