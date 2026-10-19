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

RSpec.describe 'Dashboard trip buttons for admins', type: :request do
  let(:trip) { create(:trip, :registration_closed) }
  let!(:night) { create(:night, trip: trip, date: Date.today + 30) }
  let!(:round) { create(:round, trip: trip, date: Date.today + 30) }
  let!(:site_admin) { create(:golfer, :admin) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('CURRENT_TRIP_NUMBER').and_return(trip.number)
    allow(ENV).to receive(:[]).with('SITE_ADMIN_EMAIL').and_return(site_admin.email)
    post '/login', params: { email: site_admin.email, password: 'test1234' }
    get '/dashboard'
  end

  it 'keeps Beds, Tournament, Scoreboard and Scores in the Current Trip box, above the other admin tools' do
    body = response.body
    previous_trips = body.index('value="Previous Trips"')
    ['value="Beds"', 'value="Tournament"', 'value="Scoreboard"', 'value="Scores: '].each do |button|
      expect(body.index(button)).to be < previous_trips, "#{button} should come before the other admin tools"
      expect(body.scan(button).length).to eq(1)
    end
  end

  it 'keeps the other tools in the lower card' do
    body = response.body
    top_card_end = body.index('value="Scores: ')
    %w[Broadcast Courses Roster].each { |label| expect(body.index("value=\"#{label}\"")).to be > top_card_end }
  end

  it 'puts Open Trip Registration on its own row right under the first row, before the new rows' do
    body = response.body
    expect(body.index('value="Finances"')).to be < body.index('value="Open Trip Registration"')
    expect(body.index('value="Open Trip Registration"')).to be < body.index('value="Beds"')
  end

  it 'shows a Scores button for each non-tournament round, in the Current Trip box' do
    expect(response.body).to include("Scores: #{round.date.strftime('%b %-d')}")
  end
end
