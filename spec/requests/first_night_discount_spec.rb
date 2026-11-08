require 'rails_helper'

RSpec.describe 'First-night discount', type: :request do
  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  let!(:site_admin) { create(:golfer, :admin) }
  let(:trip) { create(:trip) }
  let!(:nights) { Array.new(3) { create(:night, trip: trip, cost: 100) } }
  let!(:rounds) { Array.new(2) { create(:round, trip: trip, cost: 80) } }
  let(:golfer) { create(:golfer) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('SITE_ADMIN_EMAIL').and_return(site_admin.email)
    allow(ENV).to receive(:[]).with('CURRENT_TRIP_NUMBER').and_return(trip.number)
  end

  it 'comps the first night for every night with only some rounds' do
    log_in_as(golfer)
    post '/register_trip', params: { nights: nights.map { |n| n.id.to_s }, rounds: [rounds[0].id.to_s] }
    golfer_trip = golfer.golfer_trips.first
    expect(golfer_trip.is_full_trip).to be(true)
    expect(golfer_trip.cost).to eq(300 + 80 - 100)
    expect(golfer_trip.balance).to eq(280)
  end

  it 'comps the first night for every night with no rounds' do
    log_in_as(golfer)
    post '/register_trip', params: { nights: nights.map { |n| n.id.to_s } }
    expect(golfer.golfer_trips.first.cost).to eq(200)
  end

  it 'gives no discount when a night is missing, even with every round' do
    log_in_as(golfer)
    post '/register_trip', params: { nights: nights.first(2).map { |n| n.id.to_s }, rounds: rounds.map { |r| r.id.to_s } }
    golfer_trip = golfer.golfer_trips.first
    expect(golfer_trip.is_full_trip).to be_falsey
    expect(golfer_trip.cost).to eq(200 + 160)
  end

  it 'applies the discount when the site admin edits a trip to every night' do
    golfer_trip = create(:golfer_trip, golfer: golfer, trip: trip, cost: 0, balance: 0)
    log_in_as(site_admin)
    patch "/golfer_trips/#{golfer_trip.id}", params: { nights: nights.map { |n| n.id.to_s }, rounds: [rounds[1].id.to_s] }
    golfer_trip.reload
    expect(golfer_trip.is_full_trip).to be(true)
    expect(golfer_trip.cost).to eq(280)
  end

  it 'shows the discount in the live total once every night is ticked, whatever the rounds' do
    log_in_as(golfer)
    get '/register_trip'
    expect(response.body).to include('var isFullTrip = (nightsChecked.length === totalNights);')
  end
end
