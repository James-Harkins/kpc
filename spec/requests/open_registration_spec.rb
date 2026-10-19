require 'rails_helper'

RSpec.describe 'Open trip registration', type: :request do
  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  let!(:site_admin) { create(:golfer, :admin) }
  let(:trip) { create(:trip, :registration_closed) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('SITE_ADMIN_EMAIL').and_return(site_admin.email)
    allow(ENV).to receive(:[]).with('CURRENT_TRIP_NUMBER').and_return(trip.number)
  end

  describe 'PATCH /trips/:id/open_registration' do
    it 'opens registration for the site admin without sending any email' do
      log_in_as(site_admin)
      expect { patch "/trips/#{trip.id}/open_registration" }
        .not_to change { ActionMailer::Base.deliveries.count }
      expect(trip.reload.registration_open).to be(true)
      expect(response).to redirect_to('/dashboard')
    end

    it 'is refused for other admins' do
      log_in_as(create(:golfer, :admin))
      patch "/trips/#{trip.id}/open_registration"
      expect(trip.reload.registration_open).to be(false)
      expect(response).to redirect_to('/dashboard')
    end

    it 'is refused for regular golfers' do
      log_in_as(create(:golfer))
      patch "/trips/#{trip.id}/open_registration"
      expect(trip.reload.registration_open).to be(false)
    end
  end

  describe 'dashboard button' do
    it 'shows to the site admin while registration is closed' do
      log_in_as(site_admin)
      get '/dashboard'
      expect(response.body).to include('Open Trip Registration')
    end

    it 'goes away once registration is open' do
      trip.update!(registration_open: true)
      log_in_as(site_admin)
      get '/dashboard'
      expect(response.body).not_to include('Open Trip Registration')
    end

    it 'never shows to other admins' do
      log_in_as(create(:golfer, :admin))
      get '/dashboard'
      expect(response.body).not_to include('Open Trip Registration')
    end
  end
end
