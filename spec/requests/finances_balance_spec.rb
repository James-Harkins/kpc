require 'rails_helper'

RSpec.describe 'Finances balance display', type: :request do
  let!(:site_admin) { create(:golfer, :admin) }
  let(:trip) { create(:trip) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('SITE_ADMIN_EMAIL').and_return(site_admin.email)
    allow(ENV).to receive(:[]).with('CURRENT_TRIP_NUMBER').and_return(trip.number)
    post '/login', params: { email: site_admin.email, password: 'test1234' }
  end

  it 'puts the minus sign before the dollar sign on a negative balance' do
    create(:expense, trip: trip, golfer: site_admin, amount: 1832)
    create(:golfer_trip, trip: trip, cost: 1000, balance: 1000)
    get '/finances', params: { trip_id: trip.id }
    expect(response.body).to include('-$832')
    expect(response.body).not_to include('$-832')
  end

  it 'leaves a positive balance alone' do
    create(:golfer_trip, trip: trip, cost: 400, balance: 400)
    get '/finances', params: { trip_id: trip.id }
    expect(response.body).to match(/Balance<\/td>\s*<td>\$400<\/td>/)
  end

  it 'labels the green Mark as Paid button' do
    create(:golfer_trip, trip: trip, cost: 400, balance: 400)
    get '/finances', params: { trip_id: trip.id }
    expect(response.body).to include('btn-outline-primary-green', 'Mark this golfer as paid in full.')
  end
end
