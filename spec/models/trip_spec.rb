require 'rails_helper'

RSpec.describe Trip, type: :model do
  describe 'relationships' do
    it { should have_many(:nights) }
    it { should have_many(:rounds) }
    it { should have_many(:golfer_trips) }
    it { should have_many(:golfers).through(:golfer_trips) }
    it { should have_many(:expenses) }
    it { should have_one(:trip_financial_summary) }
    it { should have_many(:houses).dependent(:destroy) }
    it { should have_many(:bedrooms).through(:houses) }
    it { should have_many(:beds).through(:bedrooms) }
  end

  describe '#bed_priority_order' do
    let(:trip) { create(:trip, deposit_due_date: Date.new(2026, 6, 1)) }

    def register(cost:, nights: 0, registered_at: Time.utc(2026, 4, 1))
      golfer_trip = create(:golfer_trip, trip: trip, cost: cost, created_at: registered_at)
      nights.times do
        create(:golfer_night, golfer: golfer_trip.golfer, night: create(:night, trip: trip))
      end
      golfer_trip
    end

    it 'orders tier 1 (met by deadline) before tier 2 (met late) before tier 3 (not met)' do
      unmet = register(cost: 400)
      late = register(cost: 400)
      create(:payment, golfer_trip: late, amount: 200, created_at: Time.utc(2026, 6, 10))
      on_time = register(cost: 400)
      create(:payment, golfer_trip: on_time, amount: 200, created_at: Time.utc(2026, 5, 10))

      expect(trip.bed_priority_order).to eq([on_time, late, unmet])
    end

    it 'ranks more nights first within a tier' do
      short_stay = register(cost: 400, nights: 2)
      create(:payment, golfer_trip: short_stay, amount: 200, created_at: Time.utc(2026, 5, 1))
      long_stay = register(cost: 600, nights: 4)
      create(:payment, golfer_trip: long_stay, amount: 300, created_at: Time.utc(2026, 5, 20))

      expect(trip.bed_priority_order).to eq([long_stay, short_stay])
    end

    it 'breaks night ties by earlier deposit, then earlier registration' do
      second_payer = register(cost: 400, nights: 2)
      create(:payment, golfer_trip: second_payer, amount: 200, created_at: Time.utc(2026, 5, 15))
      first_payer = register(cost: 400, nights: 2)
      create(:payment, golfer_trip: first_payer, amount: 200, created_at: Time.utc(2026, 5, 5))
      late_registrant = register(cost: 400, nights: 2, registered_at: Time.utc(2026, 4, 20))
      early_registrant = register(cost: 400, nights: 2, registered_at: Time.utc(2026, 4, 10))

      expect(trip.bed_priority_order).to eq([first_payer, second_payer, early_registrant, late_registrant])
    end

    it 'places cost-zero (admin-registered) golfers in tier 1 at their registration time' do
      payer = register(cost: 400, registered_at: Time.utc(2026, 4, 1))
      create(:payment, golfer_trip: payer, amount: 200, created_at: Time.utc(2026, 5, 10))
      admin_registered = register(cost: 0, registered_at: Time.utc(2026, 4, 15))

      expect(trip.bed_priority_order).to eq([admin_registered, payer])
    end

    it 'always places admins first, regardless of nights or deposit timing' do
      early_payer = register(cost: 400, nights: 4)
      create(:payment, golfer_trip: early_payer, amount: 400, created_at: Time.utc(2026, 5, 1))
      admin_trip = create(:golfer_trip, golfer: create(:golfer, :admin), trip: trip, cost: 400)

      expect(trip.bed_priority_order).to eq([admin_trip, early_payer])
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:year) }
    it { should validate_presence_of(:number) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:start_date) }
  end

  describe '#admin_cost_breakdown with no admins' do
    it 'returns empty array when there are no admin golfers' do
      trip = Trip.create!(year: 2024, number: 'XXIV', location: 'Bethany Beach',
                           start_date: Date.new(2024, 4, 21))
      expect(trip.admin_cost_breakdown).to eq([])
    end
  end

  describe 'class methods' do
    describe '.current' do
      before do
        @trip = Trip.create!(year: 2023, number: 'XXIII', location: 'Dewey Beach',
                              start_date: Date.new(2023, 4, 16))
      end

      around do |example|
        original = ENV['CURRENT_TRIP_NUMBER']
        ENV['CURRENT_TRIP_NUMBER'] = 'XXIII'
        example.run
        ENV['CURRENT_TRIP_NUMBER'] = original
      end

      it 'returns the trip matching the CURRENT_TRIP_NUMBER env var' do
        expect(Trip.current).to eq(@trip)
      end
    end
  end

  describe 'instance methods' do
    before do
      @admin1 = Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'Tony',
                                email: 'tony@badabing.com', password: 'test1234',
                                password_confirmation: 'test1234', role: :admin, t_shirt_size: :m)
      @admin2 = Golfer.create!(first_name: 'Chris', last_name: 'Moltisanti', nickname: 'Chris',
                                email: 'chris@badabing.com', password: 'test1234',
                                password_confirmation: 'test1234', role: :admin, t_shirt_size: :m)
      @golfer = Golfer.create!(first_name: 'Bobby', last_name: 'Bacalieri', nickname: 'Bobby',
                                email: 'bobby@badabing.com', password: 'test1234',
                                password_confirmation: 'test1234', t_shirt_size: :m)

      @trip = Trip.create!(year: 2023, number: 'XXIII', location: 'Dewey Beach',
                            start_date: Date.new(2023, 4, 16))

      # Two nights, two rounds on the same dates (for calendar tests)
      @night1 = @trip.nights.create!(date: Date.new(2023, 4, 16), cost: 100)
      @night2 = @trip.nights.create!(date: Date.new(2023, 4, 17), cost: 110)
      @round1 = @trip.rounds.create!(date: Date.new(2023, 4, 16), cost: 80)
      @round2 = @trip.rounds.create!(date: Date.new(2023, 4, 17), cost: 90)

      # Golfer trips
      @golfer_trip  = @trip.golfer_trips.create!(golfer: @golfer,  cost: 100, balance: 100, is_paid: false)
      @admin1_trip  = @trip.golfer_trips.create!(golfer: @admin1,  cost: 50,  balance: 0,   is_paid: true)
      @admin2_trip  = @trip.golfer_trips.create!(golfer: @admin2,  cost: 50,  balance: 50,  is_paid: false, is_full_trip: true)

      # Golfer nights and rounds (for attendance lists in sort_by_calendar_admin)
      @golfer.golfer_nights.create!(night: @night1)
      @golfer.golfer_nights.create!(night: @night2)
      @golfer.golfer_rounds.create!(round: @round1)
      @golfer.golfer_rounds.create!(round: @round2)

      # Expense paid by admin1
      @expense = @trip.expenses.create!(golfer: @admin1, amount: 400, description: 'House rental')

      # Payment toward golfer_trip
      @payment = @golfer_trip.payments.create!(amount: 50)
    end

    describe '#sort_by_calendar' do
      it 'returns an array of calendar entries with night and round details' do
        calendar = @trip.sort_by_calendar

        expect(calendar).to be_an(Array)
        expect(calendar.length).to eq(2)

        first_entry = calendar.first
        expect(first_entry[:date]).to be_a(String)
        expect(first_entry[:night][:id]).to eq(@night1.id)
        expect(first_entry[:night][:cost]).to eq(100)
        expect(first_entry[:round][:id]).to eq(@round1.id)
        expect(first_entry[:round][:cost]).to eq(80)
      end
    end

    describe '#sort_by_calendar_admin' do
      it 'returns calendar entries with attendance counts and lists' do
        calendar = @trip.sort_by_calendar_admin

        expect(calendar).to be_an(Array)
        expect(calendar.length).to eq(2)

        first_entry = calendar.first
        expect(first_entry[:date]).to be_a(String)
        expect(first_entry[:house_attendance]).to eq(1)
        expect(first_entry[:house_attendance_list]).to include('Bobby')
        expect(first_entry[:round_attendance]).to eq(1)
        expect(first_entry[:round_attendance_list]).to include('Bobby')
      end
    end

    describe '#paid_golfer_trips' do
      it 'returns only paid golfer trips' do
        expect(@trip.paid_golfer_trips).to include(@admin1_trip)
        expect(@trip.paid_golfer_trips).not_to include(@golfer_trip)
      end
    end

    describe '#unpaid_golfer_trips' do
      it 'returns only unpaid golfer trips' do
        expect(@trip.unpaid_golfer_trips).to include(@golfer_trip)
        expect(@trip.unpaid_golfer_trips).to include(@admin2_trip)
        expect(@trip.unpaid_golfer_trips).not_to include(@admin1_trip)
      end
    end

    describe '#total_projected_revenue' do
      it 'returns the sum of all golfer_trip costs' do
        expect(@trip.total_projected_revenue).to eq(200)
      end
    end

    describe '#total_collected_revenue' do
      it 'returns the sum of all payments across golfer trips' do
        expect(@trip.total_collected_revenue).to eq(50)
      end
    end

    describe '#total_uncollected_revenue' do
      it 'returns the sum of all golfer_trip balances' do
        expect(@trip.total_uncollected_revenue).to eq(150)
      end
    end

    describe '#total_expenses' do
      it 'returns the sum of all expenses' do
        expect(@trip.total_expenses).to eq(400)
      end
    end

    describe '#balance' do
      it 'returns total_projected_revenue minus total_expenses' do
        expect(@trip.balance).to eq(-200)
      end
    end

    describe '#total_man_nights' do
      it "counts only regular golfers' nights, ignoring admins and their full trips" do
        # @golfer (regular) has 2 golfer_nights; @admin2_trip is a full trip but belongs to an admin
        expect(@trip.total_man_nights).to eq(2)
      end

      it "ignores an admin's golfer_nights" do
        @admin1.golfer_nights.create!(night: @night1)
        @admin1.golfer_nights.create!(night: @night2)
        expect(@trip.total_man_nights).to eq(2)
      end

      it 'still subtracts the comped first night for a regular golfer on a full trip' do
        @trip.golfer_trips.find_by(golfer: @golfer)&.update!(is_full_trip: true) ||
          @trip.golfer_trips.create!(golfer: @golfer, cost: 0, balance: 0, is_full_trip: true)
        expect(@trip.total_man_nights).to eq(1)
      end
    end

    describe '#number_of_full_trips' do
      it 'returns the count of golfer_trips marked as full trip' do
        expect(@trip.number_of_full_trips).to eq(1)
      end
    end

    describe '#admin_net_deficit' do
      it 'returns total_expenses minus total_projected_revenue' do
        expect(@trip.admin_net_deficit).to eq(200)
      end
    end

    describe '#admin_cost_breakdown' do
      context 'with admin golfers and a treasurer' do
        around do |example|
          original = ENV['TREASURER_EMAIL']
          ENV['TREASURER_EMAIL'] = 'tony@badabing.com'
          example.run
          ENV['TREASURER_EMAIL'] = original
        end

        it 'returns breakdown entries for each admin with correct balances' do
          breakdown = @trip.admin_cost_breakdown

          expect(breakdown.length).to eq(2)

          admin1_entry = breakdown.find { |e| e[:golfer] == @admin1 }
          admin2_entry = breakdown.find { |e| e[:golfer] == @admin2 }

          # admin1 is treasurer: adjusted_paid = 400 - 200 = 200; share = 100; balance = 100
          expect(admin1_entry[:is_treasurer]).to eq(true)
          expect(admin1_entry[:paid]).to eq(200)
          expect(admin1_entry[:fair_share]).to eq(100.0)
          expect(admin1_entry[:balance]).to eq(100.0)
          expect(admin1_entry[:expenses_paid]).to eq(400)
          expect(admin1_entry[:revenue_collected]).to eq(200)

          # admin2: expenses_paid = 0; share = 100; balance = -100
          expect(admin2_entry[:is_treasurer]).to eq(false)
          expect(admin2_entry[:paid]).to eq(0)
          expect(admin2_entry[:balance]).to eq(-100.0)
          expect(admin2_entry).not_to have_key(:expenses_paid)
        end
      end

      context 'without a treasurer set' do
        around do |example|
          original = ENV['TREASURER_EMAIL']
          ENV.delete('TREASURER_EMAIL')
          example.run
          ENV['TREASURER_EMAIL'] = original
        end

        it 'treats all admins as non-treasurers' do
          breakdown = @trip.admin_cost_breakdown
          expect(breakdown).to all(include(is_treasurer: false))
        end
      end
    end

    describe '#admin_settlements' do
      around do |example|
        original = ENV['TREASURER_EMAIL']
        ENV['TREASURER_EMAIL'] = 'tony@badabing.com'
        example.run
        ENV['TREASURER_EMAIL'] = original
      end

      it 'returns settlement entries between creditors and debtors' do
        settlements = @trip.admin_settlements

        expect(settlements.length).to eq(1)
        expect(settlements.first[:payer]).to eq(@admin2)
        expect(settlements.first[:payee]).to eq(@admin1)
        expect(settlements.first[:amount]).to eq(100)
      end

      it 'returns empty array when there are no creditors or debtors' do
        trip = Trip.create!(year: 2024, number: 'XXIV', location: 'Bethany Beach',
                             start_date: Date.new(2024, 4, 21))
        expect(trip.admin_settlements).to eq([])
      end
    end
  end
end

RSpec.describe Trip, 'previous trip helpers' do
  let(:trip) { create(:trip) }
  let(:admin) { create(:golfer, :admin) }
  let(:regular) { create(:golfer) }

  describe '#unique_attendance' do
    it 'counts registered golfers once each, admins included' do
      create(:golfer_trip, golfer: admin, trip: trip)
      create(:golfer_trip, golfer: regular, trip: trip)
      expect(trip.unique_attendance).to eq(2)
    end

    it 'is zero for a trip nobody registered for' do
      expect(trip.unique_attendance).to eq(0)
    end

    it 'ignores golfers registered for other trips' do
      create(:golfer_trip, golfer: regular, trip: create(:trip))
      expect(trip.unique_attendance).to eq(0)
    end
  end

  describe '.unique_attendance_across' do
    it 'counts a golfer who went to several trips once' do
      other = create(:trip)
      [trip, other].each { |t| create(:golfer_trip, golfer: regular, trip: t) }
      create(:golfer_trip, golfer: admin, trip: other)
      expect(Trip.unique_attendance_across([trip, other])).to eq(2)
    end

    it 'is zero for no trips' do
      expect(Trip.unique_attendance_across([])).to eq(0)
    end
  end

  describe '#expenses_by_amount' do
    it 'orders largest first, then newest date for ties' do
      small  = create(:expense, trip: trip, amount: 50,  date: Date.new(2026, 1, 1))
      big    = create(:expense, trip: trip, amount: 900, date: Date.new(2026, 1, 1))
      tie_old = create(:expense, trip: trip, amount: 200, date: Date.new(2026, 1, 1))
      tie_new = create(:expense, trip: trip, amount: 200, date: Date.new(2026, 2, 1))
      expect(trip.expenses_by_amount.to_a).to eq([big, tie_new, tie_old, small])
    end

    it 'only includes this trip' do
      create(:expense, trip: create(:trip), amount: 999)
      expect(trip.expenses_by_amount).to be_empty
    end
  end
end
