require 'rails_helper'

RSpec.describe 'Site admin registers a golfer', type: :request do
  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  let!(:site_admin) { create(:golfer, :admin) }
  let(:trip) { create(:trip) }
  let!(:nights) { Array.new(3) { create(:night, trip: trip, cost: 100) } }
  let!(:round) { create(:round, trip: trip, cost: 80) }
  let!(:elder) { create(:golfer, first_name: 'Walter', last_name: 'Gray') }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('SITE_ADMIN_EMAIL').and_return(site_admin.email)
    allow(ENV).to receive(:[]).with('CURRENT_TRIP_NUMBER').and_return(trip.number)
  end

  describe 'the dashboard button' do
    it 'shows for the site admin when the current trip is open for registration' do
      log_in_as(site_admin)
      get '/dashboard'
      expect(response.body).to include('Register a Golfer')
    end

    it 'is hidden while registration is closed' do
      trip.update!(registration_open: false)
      log_in_as(site_admin)
      get '/dashboard'
      expect(response.body).not_to include('Register a Golfer')
    end

    it 'is hidden from other admins' do
      log_in_as(create(:golfer, :admin))
      get '/dashboard'
      expect(response.body).not_to include('Register a Golfer')
    end
  end

  describe 'GET /admin/register_golfer' do
    before { log_in_as(site_admin) }

    it 'lists only default golfers who are not yet registered' do
      registered = create(:golfer, first_name: 'Already', last_name: 'There')
      create(:golfer_trip, golfer: registered, trip: trip)
      get '/admin/register_golfer'
      expect(response.body).to include('Walter Gray')
      expect(response.body).not_to include('Already There')
      expect(response.body).not_to include(site_admin.last_name + ' (')
    end

    it 'shows the registration form for the chosen golfer' do
      get '/admin/register_golfer', params: { golfer_id: elder.id }
      expect(response.body).to include('REGISTER WALTER GRAY FOR KPC', 'name="golfer_id"', elder.email)
      expect(response.body).to include(%(action="/admin/register_golfer"))
    end

    it 'refuses an admin or already-registered golfer' do
      get '/admin/register_golfer', params: { golfer_id: create(:golfer, :admin).id }
      expect(response.body).to include("That golfer can&#39;t be registered.")
    end

    it 'redirects when registration is closed' do
      trip.update!(registration_open: false)
      get '/admin/register_golfer'
      expect(response).to redirect_to('/dashboard')
    end
  end

  describe 'POST /admin/register_golfer' do
    before { log_in_as(site_admin) }

    it 'registers the chosen golfer with normal pricing and emails them the signup' do
      expect {
        post '/admin/register_golfer', params: { golfer_id: elder.id, nights: nights.map { |n| n.id.to_s }, rounds: [round.id.to_s] }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      golfer_trip = elder.golfer_trips.find_by(trip: trip)
      expect(golfer_trip.cost).to eq(300 + 80 - 100)
      expect(golfer_trip.is_full_trip).to be(true)
      expect(golfer_trip.reserved_all_week).to be(false)
      expect(site_admin.golfer_trips).to be_empty
      expect(ActionMailer::Base.deliveries.last.to).to eq([elder.email])
      expect(response).to redirect_to('/dashboard')
      expect(flash[:notice]).to eq("Registered Walter Gray for KPC #{trip.number}.")
    end

    it 'supports the whole-enchilada button' do
      post '/admin/register_golfer', params: { golfer_id: elder.id, full_trip: 'true' }
      expect(elder.golfer_trips.find_by(trip: trip).is_full_trip).to be(true)
    end

    it 'requires the deposit policy to be acknowledged when the trip has a deposit date' do
      trip.update!(deposit_due_date: Date.new(2026, 12, 1))
      post '/admin/register_golfer', params: { golfer_id: elder.id, nights: [nights[0].id.to_s] }
      expect(elder.golfer_trips).to be_empty
      expect(response).to redirect_to("/admin/register_golfer?golfer_id=#{elder.id}")

      post '/admin/register_golfer', params: { golfer_id: elder.id, nights: [nights[0].id.to_s], deposit_policy_acknowledged: '1' }
      expect(elder.golfer_trips.find_by(trip: trip).deposit_policy_acknowledged_at).to be_present
    end

    it 'refuses to register an admin' do
      other = create(:golfer, :admin)
      expect {
        post '/admin/register_golfer', params: { golfer_id: other.id, nights: [nights[0].id.to_s] }
      }.not_to change(GolferTrip, :count)
    end

    it 'refuses while registration is closed' do
      trip.update!(registration_open: false)
      expect {
        post '/admin/register_golfer', params: { golfer_id: elder.id, nights: [nights[0].id.to_s] }
      }.not_to change(GolferTrip, :count)
    end
  end

  describe 'access' do
    it 'refuses other admins and regular golfers on both routes' do
      [create(:golfer, :admin), create(:golfer)].each do |user|
        log_in_as(user)
        get '/admin/register_golfer'
        expect(response).to redirect_to('/dashboard')
        expect {
          post '/admin/register_golfer', params: { golfer_id: elder.id, nights: [nights[0].id.to_s] }
        }.not_to change(GolferTrip, :count)
        expect(response).to redirect_to('/dashboard')
      end
    end

    it 'does not let a regular golfer register someone else through the normal route' do
      stranger = create(:golfer)
      log_in_as(stranger)
      expect {
        post '/register_trip', params: { golfer_id: elder.id, nights: [nights[0].id.to_s] }
      }.to change { stranger.golfer_trips.count }.by(1)
      expect(elder.golfer_trips).to be_empty
    end
  end
end
