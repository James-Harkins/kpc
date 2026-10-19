require 'rails_helper'

RSpec.describe 'BedAlertOptOuts', type: :request do
  let(:golfer) { create(:golfer) }
  let(:trip)   { create(:trip) }
  let(:token)  { BedAlertOptOut.token_for(golfer, trip) }

  describe 'GET /bed_alerts/opt_out' do
    it 'shows a confirmation page without opting out' do
      expect { get '/bed_alerts/opt_out', params: { token: token } }.not_to change(BedAlertOptOut, :count)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("KPC #{trip.number}")
    end

    it '404s on a bad token' do
      get '/bed_alerts/opt_out', params: { token: 'nope' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /bed_alerts/opt_out' do
    it 'opts the golfer out of this trip' do
      expect { post '/bed_alerts/opt_out', params: { token: token } }.to change(BedAlertOptOut, :count).by(1)
      expect(response).to have_http_status(:ok)
      expect(trip.bed_alert_recipients).not_to include(golfer)
    end

    it 'is idempotent' do
      post '/bed_alerts/opt_out', params: { token: token }
      expect { post '/bed_alerts/opt_out', params: { token: token } }.not_to change(BedAlertOptOut, :count)
    end

    it '404s on a bad token and records nothing' do
      expect { post '/bed_alerts/opt_out', params: { token: 'nope' } }.not_to change(BedAlertOptOut, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
end
