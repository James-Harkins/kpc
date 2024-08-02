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
    it { should validate_presence_of :email }

    describe 'email' do
      before do
        golfer_1 = Golfer.create!(first_name: 'Tony', last_name: 'Soprano', email: 'wokeupthismorning@gmail.com', password: 'test123', password_confirmation: 'test123')
      end

      it { should allow_value('cleavermovie@gmail.com').for(:email) }
      it { should_not allow_value('wokeupthismorning@gmail.com').for(:email) }
    end

    it { should validate_presence_of(:password) }
    it { should have_secure_password }

    it 'should not have a password attribute and the password_digest attribute should be a hash' do
      golfer = Golfer.create!(first_name: 'Tony', last_name: 'Soprano', email: 'wokeupthismorning@gmail.com', password: 'test123', password_confirmation: 'test123')
      expect(golfer).to_not have_attribute(:password)
      expect(golfer.password_digest).to_not eq('password123')
    end

    it 'should be initialized with a default role' do
      golfer = Golfer.create!(first_name: 'Tony', last_name: 'Soprano', email: 'wokeupthismorning@gmail.com', password: 'test123', password_confirmation: 'test123')
      
      expect(golfer.role).to eq('default')
    end
  end

  describe 'instance methods' do
    before do
      @golfer_1 = Golfer.create!(first_name: 'Tony', last_name: 'Soprano', email: 't@badabing.com', password: 'test123', password_confirmation: 'test123')

      @trip_1 = Trip.create!(year: 2013, number: 'XIII', location: 'Dewey Beach')
      @trip_2 = Trip.create!(year: 2014, number: 'XIV', location: 'Rehoboth Beach')
      @trip_3 = Trip.create!(year: 2015, number: 'XV', location: 'VA Beach')
      @trip_4 = Trip.create!(year: 2016, number: 'XVI', location: 'VA Beach')

      @night_1_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-21'), cost: 70.0)
      @night_2_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-22'), cost: 70.0)
      @night_3_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-23'), cost: 70.0)
      @night_4_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-24'), cost: 70.0)
      @night_5_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-25'), cost: 70.0)
      @night_6_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-26'), cost: 70.0)
      @night_7_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-27'), cost: 70.0)

      @night_1_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-20'), cost: 80.0)
      @night_2_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-21'), cost: 80.0)
      @night_3_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-22'), cost: 80.0)
      @night_4_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-23'), cost: 80.0)
      @night_5_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-24'), cost: 80.0)
      @night_6_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-25'), cost: 80.0)
      @night_7_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-26'), cost: 80.0)

      @night_1_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-19'), cost: 90.0)
      @night_2_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-20'), cost: 90.0)
      @night_3_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-21'), cost: 90.0)
      @night_4_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-22'), cost: 90.0)
      @night_5_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-23'), cost: 90.0)
      @night_6_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-24'), cost: 90.0)
      @night_7_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-25'), cost: 90.0)

      @night_1_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-18'), cost: 100.0)
      @night_2_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-19'), cost: 100.0)
      @night_3_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-20'), cost: 100.0)
      @night_4_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-21'), cost: 100.0)
      @night_5_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-22'), cost: 100.0)
      @night_6_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-23'), cost: 100.0)
      @night_7_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-24'), cost: 100.0)

      @trip_1_course_1 = @trip_1.rounds.create!(date: Date.parse('2013-04-22'), cost: 65)
      @trip_1_course_2 = @trip_1.rounds.create!(date: Date.parse('2013-04-23'), cost: 65)
      @trip_1_course_3 = @trip_1.rounds.create!(date: Date.parse('2013-04-24'), cost: 65)
      @trip_1_course_4 = @trip_1.rounds.create!(date: Date.parse('2013-04-25'), cost: 65)
      @trip_1_course_5 = @trip_1.rounds.create!(date: Date.parse('2013-04-26'), cost: 65)
      @trip_1_course_6 = @trip_1.rounds.create!(date: Date.parse('2013-04-27'), cost: 65)

      @trip_2_course_1 = @trip_2.rounds.create!(date: Date.parse('2013-04-21'), cost: 70)
      @trip_2_course_2 = @trip_2.rounds.create!(date: Date.parse('2013-04-22'), cost: 70)
      @trip_2_course_3 = @trip_2.rounds.create!(date: Date.parse('2013-04-23'), cost: 70)
      @trip_2_course_4 = @trip_2.rounds.create!(date: Date.parse('2013-04-24'), cost: 70)
      @trip_2_course_5 = @trip_2.rounds.create!(date: Date.parse('2013-04-25'), cost: 70)
      @trip_2_course_6 = @trip_2.rounds.create!(date: Date.parse('2013-04-26'), cost: 70)

      @trip_3_course_2 = @trip_3.rounds.create!(date: Date.parse('2013-04-20'), cost: 50)
      @trip_3_course_1 = @trip_3.rounds.create!(date: Date.parse('2013-04-21'), cost: 50)
      @trip_3_course_3 = @trip_3.rounds.create!(date: Date.parse('2013-04-22'), cost: 50)
      @trip_3_course_4 = @trip_3.rounds.create!(date: Date.parse('2013-04-23'), cost: 50)
      @trip_3_course_5 = @trip_3.rounds.create!(date: Date.parse('2013-04-24'), cost: 50)
      @trip_3_course_6 = @trip_3.rounds.create!(date: Date.parse('2013-04-25'), cost: 50)

      @trip_4_course_2 = @trip_4.rounds.create!(date: Date.parse('2013-04-19'), cost: 60)
      @trip_4_course_1 = @trip_4.rounds.create!(date: Date.parse('2013-04-20'), cost: 60)
      @trip_4_course_3 = @trip_4.rounds.create!(date: Date.parse('2013-04-21'), cost: 60)
      @trip_4_course_4 = @trip_4.rounds.create!(date: Date.parse('2013-04-22'), cost: 60)
      @trip_4_course_5 = @trip_4.rounds.create!(date: Date.parse('2013-04-23'), cost: 60)
      @trip_4_course_6 = @trip_4.rounds.create!(date: Date.parse('2013-04-24'), cost: 60)

      @golfer_1_trip_1 = @golfer_1.golfer_trips.create!(trip: @trip_1)
      @golfer_1_trip_1_night_1 = @golfer_1.golfer_nights.create!(night: @night_3_trip_1)
      @golfer_1_trip_1_golfer_trip_course_1 = @golfer_1.golfer_rounds.create!(round: @trip_1_course_3)
      @golfer_1_trip_1_night_2 = @golfer_1.golfer_nights.create!(night: @night_4_trip_1)
      @golfer_1_trip_1_golfer_trip_course_2 = @golfer_1.golfer_rounds.create!(round: @trip_1_course_4)
      @golfer_1_trip_1_night_3 = @golfer_1.golfer_nights.create!(night: @night_5_trip_1)
      @golfer_1_trip_1_golfer_trip_course_3 = @golfer_1.golfer_rounds.create!(round: @trip_1_course_5)
      @golfer_1_trip_1_night_4 = @golfer_1.golfer_nights.create!(night: @night_5_trip_1)
      @golfer_1_trip_1_golfer_trip_course_4 = @golfer_1.golfer_rounds.create!(round: @trip_1_course_6)
      @golfer_1_trip_1_night_5 = @golfer_1.golfer_nights.create!(night: @night_7_trip_1)
     

      @golfer_1_trip_2 = @golfer_1.golfer_trips.create!(trip: @trip_2)
      @golfer_1_trip_2_night_1 = @golfer_1.golfer_nights.create!(night: @night_4_trip_2)
      @golfer_1_trip_2_golfer_trip_course_1 = @golfer_1.golfer_rounds.create!(round: @trip_2_course_4)
      @golfer_1_trip_2_night_2 = @golfer_1.golfer_nights.create!(night: @night_5_trip_2)
      @golfer_1_trip_2_golfer_trip_course_2 = @golfer_1.golfer_rounds.create!(round: @trip_2_course_5)
      @golfer_1_trip_2_night_3 = @golfer_1.golfer_nights.create!(night: @night_6_trip_2)
      @golfer_1_trip_2_golfer_trip_course_3 = @golfer_1.golfer_rounds.create!(round: @trip_2_course_6)
      @golfer_1_trip_2_night_4 = @golfer_1.golfer_nights.create!(night: @night_7_trip_2)
     

      @golfer_1_trip_3 = @golfer_1.golfer_trips.create!(trip: @trip_4)
      @golfer_1_trip_3_night_1 = @golfer_1.golfer_nights.create!(night: @night_1_trip_4)
      @golfer_1_trip_3_golfer_trip_course_1 = @golfer_1.golfer_rounds.create!(round: @trip_4_course_1)
      @golfer_1_trip_3_night_2 = @golfer_1.golfer_nights.create!(night: @night_2_trip_4)
      @golfer_1_trip_3_golfer_trip_course_2 = @golfer_1.golfer_rounds.create!(round: @trip_4_course_2)
      @golfer_1_trip_3_night_3 = @golfer_1.golfer_nights.create!(night: @night_3_trip_4)
      @golfer_1_trip_3_golfer_trip_course_3 = @golfer_1.golfer_rounds.create!(round: @trip_4_course_3)
      @golfer_1_trip_3_night_4 = @golfer_1.golfer_nights.create!(night: @night_4_trip_4)
      @golfer_1_trip_3_golfer_trip_course_4 = @golfer_1.golfer_rounds.create!(round: @trip_4_course_4)
      @golfer_1_trip_3_night_5 = @golfer_1.golfer_nights.create!(night: @night_5_trip_4)
      @golfer_1_trip_3_golfer_trip_course_5 = @golfer_1.golfer_rounds.create!(round: @trip_4_course_5)
      @golfer_1_trip_3_night_6 = @golfer_1.golfer_nights.create!(night: @night_6_trip_4)
      @golfer_1_trip_3_golfer_trip_course_6 = @golfer_1.golfer_rounds.create!(round: @trip_4_course_6)
      @golfer_1_trip_3_night_7 = @golfer_1.golfer_nights.create!(night: @night_7_trip_4)
    
      @golfer_1_trip_4 = @golfer_1.golfer_trips.create!(trip: @trip_3, is_full_trip: true)
    end

    describe '.trip_nights_total_cost' do
      it 'should return the total cost of all nights for a given trip' do
        expect(@golfer_1.trip_nights_total_cost(@trip_1.id)).to eq(350.0)
        expect(@golfer_1.trip_nights_total_cost(@trip_2.id)).to eq(320.0)
        expect(@golfer_1.trip_nights_total_cost(@trip_4.id)).to eq(600.0)
      end
    end

    describe '.trip_rounds_total_cost' do
      it 'should return the total cost of all courses for a given trip' do
        expect(@golfer_1.trip_rounds_total_cost(@trip_1.id)).to eq(260.0)
        expect(@golfer_1.trip_rounds_total_cost(@trip_2.id)).to eq(210.0)
        expect(@golfer_1.trip_rounds_total_cost(@trip_4.id)).to eq(360.0)
      end
    end

    describe '.trip_total_cost' do
      it 'should return the total cost for a given trip' do
        expect(@golfer_1.trip_total_cost(@trip_1.id)).to eq(660.0)
        expect(@golfer_1.trip_total_cost(@trip_2.id)).to eq(570.0)
        expect(@golfer_1.trip_total_cost(@trip_4.id)).to eq(1025.0)
      end
    end
  end
end
