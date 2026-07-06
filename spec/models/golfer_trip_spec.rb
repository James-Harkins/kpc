require 'rails_helper'

RSpec.describe GolferTrip, type: :model do
  describe 'relationships' do
    it { should belong_to(:golfer) }
    it { should belong_to(:trip) }
    it { should belong_to(:bed).optional }
    it { should have_many(:nights).through(:trip) }
    it { should have_many(:payments) }
  end

  describe 'validations' do
    it 'prevents a golfer from being registered for the same trip twice' do
      golfer = Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'T',
                               email: 't@badabing.com', password: 'test1234',
                               password_confirmation: 'test1234', t_shirt_size: :m)
      trip = Trip.create!(year: 2023, number: 'XXIII', location: 'Dewey Beach',
                           start_date: Date.new(2023, 4, 16))

      GolferTrip.create!(golfer: golfer, trip: trip)
      duplicate = GolferTrip.new(golfer: golfer, trip: trip)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:golfer_id]).to include('is already signed up for this trip')
    end

    it 'allows two golfers on a capacity-2 bed but rejects a third' do
      trip = create(:trip)
      bed = create(:bed, bedroom: create(:bedroom, house: create(:house, trip: trip)), capacity: 2)
      create(:golfer_trip, trip: trip, bed: bed)
      create(:golfer_trip, trip: trip, bed: bed)
      third = build(:golfer_trip, trip: trip, bed: bed)

      expect(third).not_to be_valid
      expect(third.errors[:bed]).to include('is already at capacity')
    end

    it 'rejects a bed from a different trip' do
      bed = create(:bed, bedroom: create(:bedroom, house: create(:house)))
      golfer_trip = build(:golfer_trip, bed: bed)

      expect(golfer_trip).not_to be_valid
      expect(golfer_trip.errors[:bed]).to include('belongs to a different trip')
    end
  end

  describe '#deposit_amount' do
    it 'is half the cost, rounded up' do
      expect(build(:golfer_trip, cost: 400).deposit_amount).to eq(200)
      expect(build(:golfer_trip, cost: 401).deposit_amount).to eq(201)
    end

    it 'is zero when cost is zero' do
      expect(build(:golfer_trip, cost: 0).deposit_amount).to eq(0)
    end
  end

  describe '#deposit_met_at' do
    let(:golfer_trip) { create(:golfer_trip, cost: 400) }

    it 'is nil with no payments' do
      expect(golfer_trip.deposit_met_at).to be_nil
    end

    it 'is nil when payments total less than the deposit' do
      create(:payment, golfer_trip: golfer_trip, amount: 199)
      expect(golfer_trip.deposit_met_at).to be_nil
    end

    it 'is the timestamp of the payment that crossed the 50% threshold' do
      create(:payment, golfer_trip: golfer_trip, amount: 100, created_at: Time.utc(2026, 5, 1))
      crossing = create(:payment, golfer_trip: golfer_trip, amount: 100, created_at: Time.utc(2026, 5, 10))
      create(:payment, golfer_trip: golfer_trip, amount: 200, created_at: Time.utc(2026, 5, 20))

      expect(golfer_trip.deposit_met_at).to eq(crossing.created_at)
    end

    it 'is the registration time when cost is zero' do
      free = create(:golfer_trip, cost: 0)
      expect(free.deposit_met_at).to eq(free.created_at)
    end

    it 'is nil when a later return drops the total below the deposit' do
      create(:payment, golfer_trip: golfer_trip, amount: 200, created_at: Time.utc(2026, 5, 1))
      create(:payment, golfer_trip: golfer_trip, amount: -100, created_at: Time.utc(2026, 5, 5))

      expect(golfer_trip.deposit_met_at).to be_nil
    end

    it 'uses the later crossing after a refund and re-payment' do
      create(:payment, golfer_trip: golfer_trip, amount: 200, created_at: Time.utc(2026, 5, 1))
      create(:payment, golfer_trip: golfer_trip, amount: -100, created_at: Time.utc(2026, 5, 5))
      second_crossing = create(:payment, golfer_trip: golfer_trip, amount: 150, created_at: Time.utc(2026, 5, 15))

      expect(golfer_trip.deposit_met_at).to eq(second_crossing.created_at)
    end

    it 'handles a single overpayment' do
      payment = create(:payment, golfer_trip: golfer_trip, amount: 400, created_at: Time.utc(2026, 5, 2))
      expect(golfer_trip.deposit_met_at).to eq(payment.created_at)
    end
  end

  describe '#deposit_met_by_deadline?' do
    it 'is false when the deposit is not met' do
      golfer_trip = create(:golfer_trip, trip: create(:trip, :with_deposit_deadline))
      expect(golfer_trip.deposit_met_by_deadline?).to be false
    end

    it 'is true when met on the deadline day' do
      trip = create(:trip, deposit_due_date: Date.new(2026, 6, 1))
      golfer_trip = create(:golfer_trip, trip: trip, cost: 400)
      create(:payment, golfer_trip: golfer_trip, amount: 200, created_at: Time.utc(2026, 6, 1, 12))

      expect(golfer_trip.deposit_met_by_deadline?).to be true
    end

    it 'is false when met after the deadline' do
      trip = create(:trip, deposit_due_date: Date.new(2026, 6, 1))
      golfer_trip = create(:golfer_trip, trip: trip, cost: 400)
      create(:payment, golfer_trip: golfer_trip, amount: 200, created_at: Time.utc(2026, 6, 2))

      expect(golfer_trip.deposit_met_by_deadline?).to be false
    end

    it 'is true when the trip has no deadline and the deposit is met' do
      golfer_trip = create(:golfer_trip, cost: 400)
      create(:payment, golfer_trip: golfer_trip, amount: 200)

      expect(golfer_trip.deposit_met_by_deadline?).to be true
    end
  end

  describe '#bed_priority_tier' do
    let(:trip) { create(:trip, deposit_due_date: Date.new(2026, 6, 1)) }
    let(:golfer_trip) { create(:golfer_trip, trip: trip, cost: 400) }

    it 'is 1 when the deposit was met by the deadline' do
      create(:payment, golfer_trip: golfer_trip, amount: 200, created_at: Time.utc(2026, 5, 1))
      expect(golfer_trip.bed_priority_tier).to eq(1)
    end

    it 'is 2 when the deposit was met after the deadline' do
      create(:payment, golfer_trip: golfer_trip, amount: 200, created_at: Time.utc(2026, 6, 15))
      expect(golfer_trip.bed_priority_tier).to eq(2)
    end

    it 'is 3 when the deposit is not met' do
      expect(golfer_trip.bed_priority_tier).to eq(3)
    end

    it 'is 0 for admins regardless of deposit status' do
      admin_trip = create(:golfer_trip, golfer: create(:golfer, :admin), trip: trip, cost: 400)
      expect(admin_trip.bed_priority_tier).to eq(0)
    end
  end
end
