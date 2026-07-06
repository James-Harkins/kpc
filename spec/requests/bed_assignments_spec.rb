require 'rails_helper'

RSpec.describe 'BedAssignments', type: :request do
  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  let(:trip) { create(:trip) }
  let(:bed) { create(:bed, bedroom: create(:bedroom, house: create(:house, trip: trip)), capacity: 2) }

  describe 'GET /bed_assignments' do
    it 'redirects non-admin golfers to the dashboard' do
      log_in_as(create(:golfer))
      get '/bed_assignments', params: { trip_id: trip.id }
      expect(response).to redirect_to('/dashboard')
    end

    it 'succeeds for admins' do
      log_in_as(create(:golfer, :admin))
      create(:golfer_trip, trip: trip)
      get '/bed_assignments', params: { trip_id: trip.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /bed_assignments' do
    before { log_in_as(create(:golfer, :admin)) }

    it 'assigns and clears beds' do
      golfer_trip = create(:golfer_trip, trip: trip)
      other = create(:golfer_trip, trip: trip, bed: bed)

      patch '/bed_assignments', params: { trip_id: trip.id, beds: { bed.id.to_s => [golfer_trip.id.to_s, ''] } }

      expect(golfer_trip.reload.bed_id).to eq(bed.id)
      expect(other.reload.bed_id).to be_nil
    end

    it 'rejects the whole submission when the same golfer is in two slots' do
      golfer_trip = create(:golfer_trip, trip: trip)

      patch '/bed_assignments', params: { trip_id: trip.id, beds: { bed.id.to_s => [golfer_trip.id.to_s, golfer_trip.id.to_s] } }

      expect(golfer_trip.reload.bed_id).to be_nil
      expect(flash[:error]).to include('more than one bed slot')
    end
  end
end
