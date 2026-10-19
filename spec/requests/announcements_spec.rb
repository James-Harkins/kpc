require 'rails_helper'

RSpec.describe 'Announcements', type: :request do
  let!(:site_admin) { create(:golfer, :admin) }
  let(:trip) { create(:trip) }
  let!(:on_trip) { create(:golfer_trip, trip: trip).golfer }
  let!(:off_trip) { create(:golfer) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('SITE_ADMIN_EMAIL').and_return(site_admin.email)
    post '/login', params: { email: site_admin.email, password: 'test1234' }
  end

  it 'queues an announcement to every golfer' do
    expect { post '/announcements', params: { trip_id: 'all', subject: 'Hi', body: 'Yo' } }
      .to have_enqueued_job(BulkMailJob).with('announcement', Golfer.ids, 'Hi', 'Yo', nil)
    expect(response).to redirect_to('/dashboard')
  end

  it 'queues a trip announcement to the trip golfers plus admins, once each' do
    expect { post '/announcements', params: { trip_id: trip.id, subject: 'Hi', body: 'Yo' } }
      .to have_enqueued_job(BulkMailJob)
      .with('announcement', a_collection_containing_exactly(on_trip.id, site_admin.id), 'Hi', 'Yo', trip)
  end
end
