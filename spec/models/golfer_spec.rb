require 'rails_helper'

RSpec.describe Golfer, type: :model do
  describe 'relationships' do
    it { should have_many(:golfer_trips) }
    it { should have_many(:trips).through(:golfer_trips) }
    it { should have_many(:golfer_nights) }
    it { should have_many(:nights).through(:golfer_nights) }
    it { should have_many(:golfer_rounds) }
    it { should have_many(:rounds).through(:golfer_rounds) }
  end

  describe 'validations' do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :nickname }
    it { should validate_presence_of :email }

    describe 'email uniqueness' do
      before do
        Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'T',
                       email: 'wokeupthismorning@gmail.com', password: 'test1234',
                       password_confirmation: 'test1234', t_shirt_size: :m)
      end

      it { should allow_value('cleavermovie@gmail.com').for(:email) }
      it { should_not allow_value('wokeupthismorning@gmail.com').for(:email) }
    end

    it { should validate_presence_of(:password) }
    it { should have_secure_password }

    it 'requires password to be at least 8 characters' do
      golfer = Golfer.new(first_name: 'Tony', last_name: 'Soprano', nickname: 'T',
                          email: 'short@test.com', password: 'short', password_confirmation: 'short',
                          t_shirt_size: :m)
      expect(golfer).not_to be_valid
      expect(golfer.errors[:password]).to include('is too short (minimum is 8 characters)')
    end

    it 'should not have a password attribute and the password_digest attribute should be a hash' do
      golfer = Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'T',
                              email: 'wokeupthismorning@gmail.com', password: 'test1234',
                              password_confirmation: 'test1234', t_shirt_size: :m)
      expect(golfer).to_not have_attribute(:password)
      expect(golfer.password_digest).to_not eq('test1234')
    end

    it 'should be initialized with a default role' do
      golfer = Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'T',
                              email: 'wokeupthismorning@gmail.com', password: 'test1234',
                              password_confirmation: 'test1234', t_shirt_size: :m)
      expect(golfer.role).to eq('default')
    end

    it 'requires t_shirt_size on create' do
      golfer = Golfer.new(first_name: 'Tony', last_name: 'Soprano', nickname: 'T',
                          email: 'nosize@test.com', password: 'test1234',
                          password_confirmation: 'test1234')
      expect(golfer).not_to be_valid
      expect(golfer.errors[:t_shirt_size]).to include("can't be blank")
    end

    it 'initializes welcome_token to false' do
      golfer = Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'T',
                              email: 'welcome@test.com', password: 'test1234',
                              password_confirmation: 'test1234', t_shirt_size: :m)
      expect(golfer.welcome_token).to eq(false)
    end
  end

  describe 'instance methods' do
    before do
      @golfer_1 = Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'T',
                                  email: 't@badabing.com', password: 'test1234',
                                  password_confirmation: 'test1234', t_shirt_size: :m)

      @trip_1 = Trip.create!(year: 2013, number: 'XIII', location: 'Dewey Beach',
                              start_date: Date.parse('2013-04-21'))
      @trip_2 = Trip.create!(year: 2014, number: 'XIV', location: 'Rehoboth Beach',
                              start_date: Date.parse('2014-04-20'))
      @trip_3 = Trip.create!(year: 2015, number: 'XV', location: 'VA Beach',
                              start_date: Date.parse('2015-04-19'))
      @trip_4 = Trip.create!(year: 2016, number: 'XVI', location: 'VA Beach',
                              start_date: Date.parse('2016-04-18'))

      @night_1_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-21'), cost: 70)
      @night_2_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-22'), cost: 75)
      @night_3_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-23'), cost: 80)
      @night_4_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-24'), cost: 85)
      @night_5_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-25'), cost: 90)
      @night_6_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-26'), cost: 95)
      @night_7_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-27'), cost: 100)

      @night_1_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-20'), cost: 80)
      @night_2_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-21'), cost: 85)
      @night_3_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-22'), cost: 90)
      @night_4_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-23'), cost: 95)
      @night_5_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-24'), cost: 100)
      @night_6_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-25'), cost: 105)
      @night_7_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-26'), cost: 110)

      @night_1_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-18'), cost: 100)
      @night_2_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-19'), cost: 105)
      @night_3_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-20'), cost: 110)
      @night_4_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-21'), cost: 115)
      @night_5_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-22'), cost: 120)
      @night_6_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-23'), cost: 125)
      @night_7_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-24'), cost: 130)

      @trip_1_round_1 = @trip_1.rounds.create!(date: Date.parse('2013-04-22'), cost: 65)
      @trip_1_round_2 = @trip_1.rounds.create!(date: Date.parse('2013-04-23'), cost: 55)
      @trip_1_round_3 = @trip_1.rounds.create!(date: Date.parse('2013-04-24'), cost: 75)
      @trip_1_round_4 = @trip_1.rounds.create!(date: Date.parse('2013-04-25'), cost: 65)
      @trip_1_round_5 = @trip_1.rounds.create!(date: Date.parse('2013-04-26'), cost: 60)
      @trip_1_round_6 = @trip_1.rounds.create!(date: Date.parse('2013-04-27'), cost: 65)

      @trip_2_round_1 = @trip_2.rounds.create!(date: Date.parse('2014-04-21'), cost: 70)
      @trip_2_round_2 = @trip_2.rounds.create!(date: Date.parse('2014-04-22'), cost: 75)
      @trip_2_round_3 = @trip_2.rounds.create!(date: Date.parse('2014-04-23'), cost: 75)
      @trip_2_round_4 = @trip_2.rounds.create!(date: Date.parse('2014-04-24'), cost: 60)
      @trip_2_round_5 = @trip_2.rounds.create!(date: Date.parse('2014-04-25'), cost: 60)
      @trip_2_round_6 = @trip_2.rounds.create!(date: Date.parse('2014-04-26'), cost: 75)

      @trip_4_round_1 = @trip_4.rounds.create!(date: Date.parse('2016-04-19'), cost: 60)
      @trip_4_round_2 = @trip_4.rounds.create!(date: Date.parse('2016-04-20'), cost: 65)
      @trip_4_round_3 = @trip_4.rounds.create!(date: Date.parse('2016-04-21'), cost: 70)
      @trip_4_round_4 = @trip_4.rounds.create!(date: Date.parse('2016-04-22'), cost: 60)
      @trip_4_round_5 = @trip_4.rounds.create!(date: Date.parse('2016-04-23'), cost: 65)
      @trip_4_round_6 = @trip_4.rounds.create!(date: Date.parse('2016-04-24'), cost: 65)

      # Golfer 1 registered for trip_1 (partial: 5 nights, 4 rounds)
      @golfer_1_trip_1 = @golfer_1.golfer_trips.create!(trip: @trip_1)
      @golfer_1.golfer_nights.create!(night: @night_3_trip_1)
      @golfer_1.golfer_nights.create!(night: @night_4_trip_1)
      @golfer_1.golfer_rounds.create!(round: @trip_1_round_3)
      @golfer_1.golfer_nights.create!(night: @night_5_trip_1)
      @golfer_1.golfer_rounds.create!(round: @trip_1_round_4)
      @golfer_1.golfer_nights.create!(night: @night_6_trip_1)
      @golfer_1.golfer_rounds.create!(round: @trip_1_round_5)
      @golfer_1.golfer_nights.create!(night: @night_7_trip_1)
      @golfer_1.golfer_rounds.create!(round: @trip_1_round_6)

      # Golfer 1 registered for trip_2 (partial: 4 nights, 3 rounds)
      @golfer_1_trip_2 = @golfer_1.golfer_trips.create!(trip: @trip_2)
      @golfer_1.golfer_nights.create!(night: @night_4_trip_2)
      @golfer_1.golfer_rounds.create!(round: @trip_2_round_4)
      @golfer_1.golfer_nights.create!(night: @night_5_trip_2)
      @golfer_1.golfer_rounds.create!(round: @trip_2_round_5)
      @golfer_1.golfer_nights.create!(night: @night_6_trip_2)
      @golfer_1.golfer_rounds.create!(round: @trip_2_round_6)
      @golfer_1.golfer_nights.create!(night: @night_7_trip_2)

      # Golfer 1 registered for trip_4 (full: all 7 nights, all 6 rounds)
      @golfer_1_trip_4 = @golfer_1.golfer_trips.create!(trip: @trip_4)
      @golfer_1.golfer_nights.create!(night: @night_1_trip_4)
      @golfer_1.golfer_rounds.create!(round: @trip_4_round_1)
      @golfer_1.golfer_nights.create!(night: @night_2_trip_4)
      @golfer_1.golfer_rounds.create!(round: @trip_4_round_2)
      @golfer_1.golfer_nights.create!(night: @night_3_trip_4)
      @golfer_1.golfer_rounds.create!(round: @trip_4_round_3)
      @golfer_1.golfer_nights.create!(night: @night_4_trip_4)
      @golfer_1.golfer_rounds.create!(round: @trip_4_round_4)
      @golfer_1.golfer_nights.create!(night: @night_5_trip_4)
      @golfer_1.golfer_rounds.create!(round: @trip_4_round_5)
      @golfer_1.golfer_nights.create!(night: @night_6_trip_4)
      @golfer_1.golfer_rounds.create!(round: @trip_4_round_6)
      @golfer_1.golfer_nights.create!(night: @night_7_trip_4)
    end

    describe '#trip_nights_total_cost' do
      it 'returns the total cost of all nights for a given trip' do
        expect(@golfer_1.trip_nights_total_cost(@trip_1.id)).to eq(450)
        expect(@golfer_1.trip_nights_total_cost(@trip_2.id)).to eq(410)
        expect(@golfer_1.trip_nights_total_cost(@trip_4.id)).to eq(805)
      end
    end

    describe '#trip_rounds_total_cost' do
      it 'returns the total cost of all rounds for a given trip' do
        expect(@golfer_1.trip_rounds_total_cost(@trip_1.id)).to eq(265)
        expect(@golfer_1.trip_rounds_total_cost(@trip_2.id)).to eq(195)
        expect(@golfer_1.trip_rounds_total_cost(@trip_4.id)).to eq(385)
      end
    end

    describe '#trip_gross_total_cost' do
      it 'returns nights + rounds cost for a trip' do
        expect(@golfer_1.trip_gross_total_cost(@trip_1.id)).to eq(715)
        expect(@golfer_1.trip_gross_total_cost(@trip_4.id)).to eq(1190)
      end
    end

    describe '#trip_net_total_cost' do
      it 'returns gross total when not a full trip' do
        expect(@golfer_1.trip_net_total_cost(@trip_1.id)).to eq(715)
        expect(@golfer_1.trip_net_total_cost(@trip_2.id)).to eq(605)
        expect(@golfer_1.trip_net_total_cost(@trip_4.id)).to eq(1190)
      end

      it 'subtracts first night cost when is_full_trip is true' do
        @golfer_1_trip_4.update!(is_full_trip: true)
        # gross = 1190, first night of trip_4 cost = 100
        expect(@golfer_1.trip_net_total_cost(@trip_4.id)).to eq(1090)
      end
    end

    describe '#trip_first_night_cost' do
      it 'returns the cost of the first night for the golfer_trip trip' do
        expect(@golfer_1.trip_first_night_cost(@golfer_1_trip_1)).to eq(70)
        expect(@golfer_1.trip_first_night_cost(@golfer_1_trip_4)).to eq(100)
      end
    end

    describe '#is_registered_for_next_trip' do
      it 'returns true when golfer is registered for the trip' do
        expect(@golfer_1.is_registered_for_next_trip(@trip_1)).to eq(true)
        expect(@golfer_1.is_registered_for_next_trip(@trip_4)).to eq(true)
      end

      it 'returns false when golfer is not registered for the trip' do
        expect(@golfer_1.is_registered_for_next_trip(@trip_3)).to eq(false)
      end
    end

    describe '#trip_night_calendar' do
      it 'returns an array of day names for the golfer nights on a trip' do
        result = @golfer_1.trip_night_calendar(@trip_1.id)
        expect(result).to be_an(Array)
        expect(result.length).to eq(5)
        expect(result).to all(be_a(String))
      end
    end

    describe '#trip_round_calendar' do
      it 'returns an array of day names for the golfer rounds on a trip' do
        result = @golfer_1.trip_round_calendar(@trip_1.id)
        expect(result).to be_an(Array)
        expect(result.length).to eq(4)
        expect(result).to all(be_a(String))
      end
    end

    describe '#registered_full_trip' do
      it 'returns true when golfer has all 7 nights and 6 rounds' do
        expect(@golfer_1.registered_full_trip(@trip_4.id)).to eq(true)
      end

      it 'returns false when golfer has fewer than 7 nights or 6 rounds' do
        expect(@golfer_1.registered_full_trip(@trip_1.id)).to eq(false)
      end
    end

    describe '#generate_password_reset_token!' do
      it 'returns a raw token string and sets hashed token + timestamp on the golfer' do
        raw_token = @golfer_1.generate_password_reset_token!
        @golfer_1.reload

        expect(raw_token).to be_a(String)
        expect(@golfer_1.password_reset_token).to eq(Digest::SHA256.hexdigest(raw_token))
        expect(@golfer_1.password_reset_sent_at).to be_within(5.seconds).of(Time.zone.now)
      end
    end

    describe '#password_reset_expired?' do
      it 'returns false when token was sent within 2 hours' do
        @golfer_1.update_columns(password_reset_sent_at: 1.hour.ago)
        expect(@golfer_1.password_reset_expired?).to eq(false)
      end

      it 'returns true when token was sent more than 2 hours ago' do
        @golfer_1.update_columns(password_reset_sent_at: 3.hours.ago)
        expect(@golfer_1.password_reset_expired?).to eq(true)
      end
    end

    describe '#welcome_token_expired?' do
      it 'returns false when password_reset_sent_at is within 72 hours' do
        @golfer_1.update_columns(password_reset_sent_at: 71.hours.ago)
        expect(@golfer_1.welcome_token_expired?).to eq(false)
      end

      it 'returns true when password_reset_sent_at is more than 72 hours ago' do
        @golfer_1.update_columns(password_reset_sent_at: 73.hours.ago)
        expect(@golfer_1.welcome_token_expired?).to eq(true)
      end

      it 'returns false for a token sent 3 hours ago (within 72-hour window)' do
        @golfer_1.update_columns(password_reset_sent_at: 3.hours.ago)
        expect(@golfer_1.welcome_token_expired?).to eq(false)
      end
    end
  end
end
