require 'rails_helper'

RSpec.describe 'Dashboard for a registered golfer', type: :request do
  let(:trip) { create(:trip) }
  let!(:night) { create(:night, trip: trip, date: Date.today + 30) }
  let(:golfer) { create(:golfer) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('CURRENT_TRIP_NUMBER').and_return(trip.number)
    create(:golfer_night, golfer: golfer, night: night)
    create(:golfer_trip, golfer: golfer, trip: trip, cost: 400, balance: 400)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  it 'shows balance and payment details above the itinerary' do
    get '/dashboard'
    body = response.body
    expect(body).to include('Your Balance', 'Payment Instructions', 'iti-calendar')
    expect(body.index('Your Balance')).to be < body.index('Payment Instructions')
    expect(body.index('Payment Instructions')).to be < body.index('class="iti-calendar"')
  end

  it 'puts the golf itinerary after the balance too' do
    create(:round, trip: trip, date: night.date)
    create(:golfer_round, golfer: golfer, round: trip.rounds.first)
    get '/dashboard'
    expect(response.body.index('Your Balance')).to be < response.body.index('Golf Itinerary')
  end
end
