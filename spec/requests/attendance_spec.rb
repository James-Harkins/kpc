require 'rails_helper'

RSpec.describe 'Attendance open bed count', type: :request do
  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  let(:trip) { create(:trip) }
  let!(:nights) { Array.new(2) { create(:night, trip: trip) } }
  let(:room) { create(:bedroom, house: create(:house, trip: trip)) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('CURRENT_TRIP_NUMBER').and_return(trip.number)
    log_in_as(create(:golfer, :admin))
  end

  it 'shows the open bed count for the current trip' do
    create(:bed, bedroom: room, capacity: 2)
    create(:golfer_night, night: nights[0])
    get '/attendance', params: { trip_id: trip.id }
    expect(response.body).to include('Open Bed Count', '2 of 2 open')
    expect(response.body).to include("#{nights[0].date.strftime('%a %-m/%-d')}: 1")
    expect(response.body).to include("#{nights[1].date.strftime('%a %-m/%-d')}: 2")
  end

  it 'headlines the best night when every night has a taker' do
    create(:bed, bedroom: room, capacity: 2)
    golfer = create(:golfer)
    nights.each { |night| create(:golfer_night, golfer: golfer, night: night) }
    get '/attendance', params: { trip_id: trip.id }
    expect(response.body).to include('1 of 2 open')
  end

  it 'says so when the house is full' do
    create(:bed, bedroom: room, capacity: 1)
    create(:golfer_night, night: nights[0])
    create(:golfer_night, night: nights[1])
    get '/attendance', params: { trip_id: trip.id }
    expect(response.body).to include('0 of 1 open', 'Every night is full')
  end

  it 'says when no beds have been entered' do
    get '/attendance', params: { trip_id: trip.id }
    expect(response.body).to include('No beds have been entered')
  end

  it 'leaves the count off other trips' do
    other = create(:trip)
    get '/attendance', params: { trip_id: other.id }
    expect(response.body).not_to include('Open Bed Count')
  end

  it 'leaves the count off a completed trip' do
    trip.update!(completed: true)
    get '/attendance', params: { trip_id: trip.id }
    expect(response.body).not_to include('Open Bed Count')
  end
end
