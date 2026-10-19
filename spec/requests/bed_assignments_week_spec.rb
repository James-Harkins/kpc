require 'rails_helper'

RSpec.describe 'BedAssignments week view', type: :request do
  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  let(:trip) { create(:trip) }
  let!(:nights) { Array.new(3) { create(:night, trip: trip) } }
  let(:house) { create(:house, trip: trip, name: 'Main House') }
  let(:room) { create(:bedroom, house: house, name: 'Master Suite') }
  let(:king) { create(:bed, bedroom: room, description: 'King', capacity: 2, rank: 1) }

  def attend(golfer_trip, *attended)
    attended.each { |night| create(:golfer_night, golfer: golfer_trip.golfer, night: night) }
  end

  it 'redirects non-admin golfers' do
    log_in_as(create(:golfer))
    get '/bed_assignments/week', params: { trip_id: trip.id }
    expect(response).to redirect_to('/dashboard')
  end

  it 'redirects logged-out visitors to login' do
    get '/bed_assignments/week', params: { trip_id: trip.id }
    expect(response).to redirect_to('/login')
  end

  context 'as an admin' do
    let(:admin) { create(:golfer, :admin, nickname: 'boss') }

    before { log_in_as(admin) }

    it 'shows each bedroom with its beds and nights' do
      king
      get '/bed_assignments/week', params: { trip_id: trip.id }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Main House', 'Master Suite', 'King')
      nights.each { |night| expect(response.body).to include(night.date.strftime('%a %-m/%-d')) }
    end

    it 'keeps a reserved-all-week bed held on nights its golfer is away, never open' do
      admin_trip = create(:golfer_trip, golfer: admin, trip: trip, bed: king, reserved_all_week: true)
      attend(admin_trip, nights[1], nights[2])
      get '/bed_assignments/week', params: { trip_id: trip.id }
      expect(response.body.scan('Boss').length).to eq(3)
      expect(response.body.scan('away &mdash; reserved</span>').length).to eq(1)
      expect(response.body.scan('>open</td>').length).to eq(3)
    end

    it 'shows an unreserved bed as open on nights its golfer is away' do
      admin_trip = create(:golfer_trip, golfer: admin, trip: trip, bed: king)
      attend(admin_trip, nights[1], nights[2])
      get '/bed_assignments/week', params: { trip_id: trip.id }
      expect(response.body.scan('Boss').length).to eq(2)
      expect(response.body).not_to include('away &mdash; reserved</span>')
      expect(response.body.scan('>open</td>').length).to eq(4)
    end

    it 'shows an open slot on a half-full shared bed' do
      admin_trip = create(:golfer_trip, golfer: admin, trip: trip, bed: king)
      attend(admin_trip, *nights)
      get '/bed_assignments/week', params: { trip_id: trip.id }
      expect(response.body).to include('slot 1', 'slot 2')
      expect(response.body.scan('>open</td>').length).to eq(3)
    end

    it 'lists unassigned golfers on the nights they need a bed' do
      king
      other = create(:golfer, nickname: 'late')
      other_trip = create(:golfer_trip, golfer: other, trip: trip)
      attend(other_trip, nights[2])
      get '/bed_assignments/week', params: { trip_id: trip.id }
      expect(response.body).to include('Late')
      expect(response.body.scan('needs bed').length).to eq(1)
    end

    it 'shows attending versus total bed spots per night' do
      king
      one = create(:golfer_trip, trip: trip)
      attend(one, nights[0])
      get '/bed_assignments/week', params: { trip_id: trip.id }
      expect(response.body).to include('1 / 2', '0 / 2')
    end

    it 'handles a trip with no houses' do
      get '/bed_assignments/week', params: { trip_id: trip.id }
      expect(response.body).to include('No houses have been added')
    end
  end
end
