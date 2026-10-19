require 'rails_helper'

RSpec.describe 'Registration on full nights', type: :request do
  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  let(:trip) { create(:trip) }
  let!(:nights) { Array.new(3) { create(:night, trip: trip) } }
  let(:room) { create(:bedroom, house: create(:house, trip: trip)) }
  let(:golfer) { create(:golfer) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('CURRENT_TRIP_NUMBER').and_return(trip.number)
    create(:bed, bedroom: room, capacity: 1)
    # night 1 is full; nights 0 and 2 are open
    create(:golfer_night, night: nights[1])
    log_in_as(golfer)
  end

  it 'rejects a signup that includes a full night, and says which' do
    expect { post '/register_trip', params: { nights: [nights[0].id.to_s, nights[1].id.to_s], rounds: [] } }
      .not_to change(GolferTrip, :count)
    expect(response).to redirect_to('/register_trip')
    follow_redirect!
    expect(response.body).to include('already full on', nights[1].date.strftime('%a %-m/%-d'))
    expect(golfer.golfer_nights.count).to eq(0)
  end

  it 'rejects the full-trip button while any night is full' do
    expect { post '/register_trip', params: { full_trip: '1' } }.not_to change(GolferTrip, :count)
    expect(golfer.golfer_nights.count).to eq(0)
  end

  it 'allows a signup that only uses nights with room' do
    expect { post '/register_trip', params: { nights: [nights[0].id.to_s, nights[2].id.to_s], rounds: [] } }
      .to change(GolferTrip, :count).by(1)
    expect(golfer.golfer_nights.count).to eq(2)
  end

  it 'does not block admins' do
    admin = create(:golfer, :admin)
    log_in_as(admin)
    expect { post '/register_trip', params: { full_trip: '1' } }.to change(GolferTrip, :count).by(1)
  end

  it 'disables full nights and hides the whole-trip button on the form' do
    get '/register_trip'
    expect(response.body).to include('House full', "can't be booked")
    expect(response.body).not_to include('Give me the whole enchilada, bud!')
    expect(response.body).to match(/<input[^>]*value="#{nights[1].id}"[^>]*disabled/)
  end

  it 'leaves the form alone when nothing is full' do
    GolferNight.destroy_all
    get '/register_trip'
    expect(response.body).to include('Give me the whole enchilada, bud!')
    expect(response.body).not_to include('House full')
  end

  it 'blocks nothing before any beds are entered' do
    Bed.destroy_all
    expect { post '/register_trip', params: { full_trip: '1' } }.to change(GolferTrip, :count).by(1)
  end
end
