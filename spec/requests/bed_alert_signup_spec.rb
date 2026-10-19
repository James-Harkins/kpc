require 'rails_helper'

RSpec.describe 'Bed alerts on signup', type: :request do
  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  let(:trip) { create(:trip) }
  let!(:night) { create(:night, trip: trip) }
  let!(:waiting) { create(:golfer) }
  let!(:admin) { create(:golfer, :admin) }
  let(:signer) { create(:golfer) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('CURRENT_TRIP_NUMBER').and_return(trip.number)
    create(:bed, bedroom: create(:bedroom, house: create(:house, trip: trip)), capacity: 2)
    log_in_as(signer)
  end

  it 'emails unregistered golfers after a signup' do
    expect { post '/register_trip', params: { full_trip: '1' } }
      .to have_enqueued_job(BulkMailJob).with('bed_availability', a_collection_including(waiting.id), trip)
  end

  it 'alerts the admins when the signup fills the last open spot' do
    create(:golfer_night, night: night)
    expect { post '/register_trip', params: { full_trip: '1' } }
      .to have_enqueued_job(BulkMailJob).with('bed_capacity_reached', [admin.id], trip)
  end

  it 'does not alert the admins when spots remain' do
    expect { post '/register_trip', params: { full_trip: '1' } }
      .not_to have_enqueued_job(BulkMailJob).with('bed_capacity_reached', anything, trip)
  end

  it 'does not email golfers who already opted out' do
    create(:bed_alert_opt_out, golfer: waiting, trip: trip)
    expect { post '/register_trip', params: { full_trip: '1' } }
      .to have_enqueued_job(BulkMailJob).with('bed_availability', [admin.id], trip)
  end
end
