require 'rails_helper'

RSpec.describe GolferTripFacade do
  let(:golfer) do
    Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'T',
                   email: 't@badabing.com', password: 'test1234',
                   password_confirmation: 'test1234', t_shirt_size: :m)
  end
  let(:trip) do
    Trip.create!(year: 2023, number: 'XXIII', location: 'Dewey Beach',
                 start_date: Date.new(2023, 4, 16))
  end
  let!(:night1) { trip.nights.create!(date: Date.new(2023, 4, 16), cost: 100) }
  let!(:night2) { trip.nights.create!(date: Date.new(2023, 4, 17), cost: 110) }
  let!(:round1) { trip.rounds.create!(date: Date.new(2023, 4, 16), cost: 80) }
  let!(:round2) { trip.rounds.create!(date: Date.new(2023, 4, 17), cost: 90) }

  describe '.create_new_golfer_trip' do
    context 'when full_trip param is true' do
      let(:params) { { full_trip: true, nights: [], rounds: [] } }

      it 'creates golfer_nights for all trip nights' do
        GolferTripFacade.create_new_golfer_trip(golfer, trip, params)
        expect(golfer.nights.where(trip_id: trip.id).count).to eq(2)
      end

      it 'creates golfer_rounds for all trip rounds' do
        GolferTripFacade.create_new_golfer_trip(golfer, trip, params)
        expect(golfer.rounds.where(trip_id: trip.id).count).to eq(2)
      end

      it 'returns an unsaved GolferTrip with is_full_trip set to true' do
        golfer_trip = GolferTripFacade.create_new_golfer_trip(golfer, trip, params)
        expect(golfer_trip).to be_a(GolferTrip)
        expect(golfer_trip.is_full_trip).to eq(true)
        expect(golfer_trip).to be_new_record
      end
    end

    context 'when partial nights and rounds are selected' do
      let(:params) do
        { nights: [night1.id.to_s], rounds: [round1.id.to_s, round2.id.to_s] }
      end

      it 'creates golfer_nights only for the selected nights' do
        GolferTripFacade.create_new_golfer_trip(golfer, trip, params)
        expect(golfer.nights.where(trip_id: trip.id)).to include(night1)
        expect(golfer.nights.where(trip_id: trip.id)).not_to include(night2)
      end

      it 'creates golfer_rounds for the selected rounds' do
        GolferTripFacade.create_new_golfer_trip(golfer, trip, params)
        expect(golfer.rounds.where(trip_id: trip.id).count).to eq(2)
      end

      it 'does not set is_full_trip when nights/rounds counts do not match trip totals' do
        golfer_trip = GolferTripFacade.create_new_golfer_trip(golfer, trip, params)
        expect(golfer_trip.is_full_trip).to be_nil
      end
    end

    context 'when all nights and rounds are selected (no full_trip flag)' do
      let(:params) do
        { nights: [night1.id.to_s, night2.id.to_s], rounds: [round1.id.to_s, round2.id.to_s] }
      end

      it 'sets is_full_trip to true when counts match trip totals' do
        golfer_trip = GolferTripFacade.create_new_golfer_trip(golfer, trip, params)
        expect(golfer_trip.is_full_trip).to eq(true)
      end
    end

    it 'ignores night IDs that do not belong to the trip' do
      params = { nights: ['99999'], rounds: [] }
      GolferTripFacade.create_new_golfer_trip(golfer, trip, params)
      expect(golfer.nights.where(trip_id: trip.id).count).to eq(0)
    end
  end

  describe '.is_full_trip' do
    it 'returns true when full_trip param is set' do
      params = { full_trip: true, nights: [], rounds: [] }
      expect(GolferTripFacade.is_full_trip(params, trip)).to eq(true)
    end

    it 'returns true when nights and rounds counts match trip totals' do
      params = { nights: [night1.id, night2.id], rounds: [round1.id, round2.id] }
      expect(GolferTripFacade.is_full_trip(params, trip)).to eq(true)
    end

    it 'returns false when neither condition is met' do
      params = { nights: [night1.id], rounds: [round1.id] }
      expect(GolferTripFacade.is_full_trip(params, trip)).to be_falsey
    end
  end
end
