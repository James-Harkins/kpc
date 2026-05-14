require 'rails_helper'

RSpec.describe GolferTrip, type: :model do
  describe 'relationships' do
    it { should belong_to(:golfer) }
    it { should belong_to(:trip) }
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
  end
end
