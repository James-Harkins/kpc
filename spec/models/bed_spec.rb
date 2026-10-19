require 'rails_helper'

RSpec.describe Bed, type: :model do
  describe 'relationships' do
    it { should belong_to(:bedroom) }
    it { should have_one(:house).through(:bedroom) }
    it { should have_many(:golfer_trips) }
  end

  describe 'validations' do
    it { should validate_inclusion_of(:capacity).in_array([1, 2]) }
    it { should validate_presence_of(:rank) }

    it 'rejects a rank already used by another bed on the same trip, even in another house' do
      trip = create(:trip)
      house_a = create(:house, trip: trip)
      house_b = create(:house, trip: trip)
      create(:bed, bedroom: create(:bedroom, house: house_a), rank: 1)
      clash = build(:bed, bedroom: create(:bedroom, house: house_b), rank: 1)

      expect(clash).not_to be_valid
      expect(clash.errors[:rank].first).to include('already taken')
    end

    it 'allows the same rank on a different trip' do
      create(:bed, bedroom: create(:bedroom, house: create(:house)), rank: 1)
      other_trip_bed = build(:bed, bedroom: create(:bedroom, house: create(:house)), rank: 1)

      expect(other_trip_bed).to be_valid
    end

    it 'prevents shrinking capacity below the current occupant count' do
      trip = create(:trip)
      bed = create(:bed, bedroom: create(:bedroom, house: create(:house, trip: trip)), capacity: 2)
      night = create(:night, trip: trip)
      2.times do
        golfer_trip = create(:golfer_trip, trip: trip, bed: bed)
        create(:golfer_night, golfer: golfer_trip.golfer, night: night)
      end

      bed.capacity = 1

      expect(bed).not_to be_valid
      expect(bed.errors[:capacity].first).to include('current occupants')
    end

    it 'allows shrinking capacity when the occupants never overlap' do
      trip = create(:trip)
      bed = create(:bed, bedroom: create(:bedroom, house: create(:house, trip: trip)), capacity: 2)
      nights = Array.new(2) { create(:night, trip: trip) }
      nights.each do |night|
        golfer_trip = create(:golfer_trip, trip: trip, bed: bed)
        create(:golfer_night, golfer: golfer_trip.golfer, night: night)
      end

      bed.capacity = 1

      expect(bed).to be_valid
    end
  end
end
