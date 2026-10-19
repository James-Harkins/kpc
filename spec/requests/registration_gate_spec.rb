require 'rails_helper'

RSpec.describe 'Registration gate', type: :request do
  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  let(:trip) { create(:trip, :registration_closed) }
  let!(:night) { create(:night, trip: trip) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('CURRENT_TRIP_NUMBER').and_return(trip.number)
  end

  context 'while registration is closed' do
    it 'keeps regular golfers off the signup form' do
      log_in_as(create(:golfer))
      get '/register_trip'
      expect(response).to redirect_to('/dashboard')
    end

    it 'rejects a regular golfer who posts to signup anyway' do
      golfer = create(:golfer)
      log_in_as(golfer)
      expect { post '/register_trip', params: { full_trip: '1' } }.not_to change(GolferTrip, :count)
      expect(response).to redirect_to('/dashboard')
      expect(golfer.golfer_nights.count).to eq(0)
    end

    it 'lets admins sign up and reserves their bed all week' do
      admin = create(:golfer, :admin)
      log_in_as(admin)
      expect { post '/register_trip', params: { full_trip: '1' } }.to change(GolferTrip, :count).by(1)
      expect(admin.golfer_trips.first.reserved_all_week).to be(true)
    end

    it 'registers an admin only for the nights they pick, at no cost, with the bed reserved all week' do
      night_two = create(:night, trip: trip)
      create(:night, trip: trip)
      admin = create(:golfer, :admin)
      log_in_as(admin)
      post '/register_trip', params: { nights: [night.id.to_s, night_two.id.to_s], rounds: [] }
      golfer_trip = admin.golfer_trips.first
      expect(admin.golfer_nights.count).to eq(2)
      expect(golfer_trip.is_full_trip).to be_falsey
      expect([golfer_trip.cost, golfer_trip.balance, golfer_trip.is_paid]).to eq([0, 0, true])
      expect(golfer_trip.reserved_all_week).to be(true)
    end

    it 'shows admins a $0 total and the committee note on the signup form' do
      log_in_as(create(:golfer, :admin))
      get '/register_trip'
      expect(response.body).to include('var isAdmin = true;', 'Committee registration')
    end

    it 'does not email golfers about beds for an admin signup' do
      log_in_as(create(:golfer, :admin))
      create(:bed, bedroom: create(:bedroom, house: create(:house, trip: trip)), capacity: 2)
      expect { post '/register_trip', params: { full_trip: '1' } }
        .not_to have_enqueued_job(BulkMailJob).with('bed_availability', anything, trip)
    end

    it 'tells regular golfers on the dashboard that registration is not open' do
      log_in_as(create(:golfer))
      get '/dashboard'
      expect(response.body).to include("isn't open yet")
    end
  end

  context 'once registration is open' do
    before { trip.update!(registration_open: true) }

    it 'does not show regular golfers the committee note' do
      log_in_as(create(:golfer))
      get '/register_trip'
      expect(response.body).to include('var isAdmin = false;')
      expect(response.body).not_to include('Committee registration')
    end

    it 'lets regular golfers sign up, unreserved' do
      golfer = create(:golfer)
      log_in_as(golfer)
      expect { post '/register_trip', params: { full_trip: '1' } }.to change(GolferTrip, :count).by(1)
      expect(golfer.golfer_trips.first.reserved_all_week).to be(false)
    end
  end
end
