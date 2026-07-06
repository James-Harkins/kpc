require 'rails_helper'

RSpec.describe 'Houses', type: :request do
  around do |example|
    orig = ENV['SITE_ADMIN_EMAIL']
    ENV['SITE_ADMIN_EMAIL'] = 'siteadmin@kpc.com'
    example.run
    ENV['SITE_ADMIN_EMAIL'] = orig
  end

  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  let(:trip) { create(:trip) }
  let(:site_admin) { create(:golfer, :admin, email: 'siteadmin@kpc.com') }

  describe 'access control' do
    it 'redirects regular admins to the dashboard' do
      log_in_as(create(:golfer, :admin))
      get '/houses', params: { trip_id: trip.id }
      expect(response).to redirect_to('/dashboard')
    end
  end

  describe 'CRUD' do
    before { log_in_as(site_admin) }

    it 'renders the index and new pages' do
      create(:bed, bedroom: create(:bedroom, house: create(:house, trip: trip)))
      get '/houses', params: { trip_id: trip.id }
      expect(response).to have_http_status(:ok)

      get '/houses/new', params: { trip_id: trip.id }
      expect(response).to have_http_status(:ok)
    end

    it 'creates a house with bedrooms and beds from dynamic rows' do
      post '/houses', params: {
        trip_id: trip.id,
        house: { name: 'Main House', address: '123 Beach Ave', url: 'https://vrbo.com/main' },
        new_beds: {
          '0' => { bedroom_name: 'Master', description: 'King', capacity: '2', rank: '1' },
          '1' => { bedroom_name: 'Bunk Room', description: 'Bunk (top)', capacity: '1', rank: '2' },
          '2' => { bedroom_name: 'Bunk Room', description: 'Bunk (bottom)', capacity: '1', rank: '3' }
        }
      }

      house = trip.houses.find_by(name: 'Main House')
      expect(house.url).to eq('https://vrbo.com/main')
      expect(house.bedrooms.count).to eq(2)
      expect(house.beds.count).to eq(3)
      expect(response).to redirect_to("/houses?trip_id=#{trip.id}")
    end

    it 'flashes an error and saves nothing when a rank is duplicated' do
      post '/houses', params: {
        trip_id: trip.id,
        house: { name: 'Main House' },
        new_beds: {
          '0' => { bedroom_name: 'Master', description: 'King', capacity: '1', rank: '1' },
          '1' => { bedroom_name: 'Den', description: 'Futon', capacity: '1', rank: '1' }
        }
      }

      expect(trip.houses.count).to eq(0)
      expect(flash[:error]).to include('already taken')
    end

    it 'updates beds, swaps ranks, and removes checked beds' do
      house = create(:house, trip: trip)
      bedroom = create(:bedroom, house: house, name: 'Master')
      bed_one = create(:bed, bedroom: bedroom, rank: 1)
      bed_two = create(:bed, bedroom: bedroom, rank: 2)
      bed_three = create(:bed, bedroom: bedroom, rank: 3)

      patch "/houses/#{house.id}", params: {
        house: { name: house.name, address: '', url: '' },
        beds: {
          bed_one.id.to_s => { bedroom_name: 'Master', description: 'King', capacity: '1', rank: '2' },
          bed_two.id.to_s => { bedroom_name: 'Master', description: 'Queen', capacity: '1', rank: '1' },
          bed_three.id.to_s => { bedroom_name: 'Master', description: 'Twin', capacity: '1', rank: '3', _destroy: '1' }
        }
      }

      expect(bed_one.reload.rank).to eq(2)
      expect(bed_two.reload.rank).to eq(1)
      expect(Bed.exists?(bed_three.id)).to be false
    end

    it 'destroys a house and unassigns its occupants' do
      house = create(:house, trip: trip)
      bed = create(:bed, bedroom: create(:bedroom, house: house))
      golfer_trip = create(:golfer_trip, trip: trip, bed: bed)

      delete "/houses/#{house.id}"

      expect(House.exists?(house.id)).to be false
      expect(golfer_trip.reload.bed_id).to be_nil
    end
  end
end
