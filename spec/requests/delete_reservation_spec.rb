require 'rails_helper'

RSpec.describe 'Deleting a reservation', type: :request do
  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  let!(:site_admin) { create(:golfer, :admin) }
  let(:trip) { create(:trip) }
  let(:golfer) { create(:golfer) }
  let!(:night) { create(:night, trip: trip) }
  let!(:round) { create(:round, trip: trip) }
  let!(:golfer_trip) { create(:golfer_trip, golfer: golfer, trip: trip) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('SITE_ADMIN_EMAIL').and_return(site_admin.email)
    allow(ENV).to receive(:[]).with('CURRENT_TRIP_NUMBER').and_return(trip.number)
    create(:golfer_night, golfer: golfer, night: night)
    create(:golfer_round, golfer: golfer, round: round, score: 88)
  end

  it "clears the golfer's nights, rounds and trip for that trip only" do
    other_trip = create(:trip)
    other_night = create(:night, trip: other_trip)
    other_round = create(:round, trip: other_trip)
    create(:golfer_night, golfer: golfer, night: other_night)
    create(:golfer_round, golfer: golfer, round: other_round)
    create(:golfer_trip, golfer: golfer, trip: other_trip)

    log_in_as(site_admin)
    delete "/golfer_trips/#{golfer_trip.id}"

    expect(response).to redirect_to("/finances?trip_id=#{trip.id}")
    expect(GolferTrip.where(golfer: golfer, trip: trip)).to be_empty
    expect(GolferNight.where(golfer: golfer, night: night)).to be_empty
    expect(GolferRound.where(golfer: golfer, round: round)).to be_empty
    expect(GolferTrip.where(golfer: golfer, trip: other_trip)).to exist
    expect(GolferNight.where(golfer: golfer, night: other_night)).to exist
    expect(GolferRound.where(golfer: golfer, round: other_round)).to exist
  end

  it 'refuses while net payments are above zero' do
    create(:payment, golfer_trip: golfer_trip, amount: 100)
    log_in_as(site_admin)
    delete "/golfer_trips/#{golfer_trip.id}"
    expect(golfer_trip.reload).to be_present
    expect(GolferNight.where(golfer: golfer)).to exist
    expect(flash[:error]).to include('Process a return first')
  end

  it 'allows deletion once payments are fully returned' do
    create(:payment, golfer_trip: golfer_trip, amount: 100)
    create(:payment, golfer_trip: golfer_trip, amount: -100)
    log_in_as(site_admin)
    expect { delete "/golfer_trips/#{golfer_trip.id}" }.to change(GolferTrip, :count).by(-1)
  end

  it 'refuses on a completed trip' do
    trip.update!(completed: true)
    log_in_as(site_admin)
    expect { delete "/golfer_trips/#{golfer_trip.id}" }.not_to change(GolferTrip, :count)
  end

  it 'is refused for other admins and golfers' do
    [create(:golfer, :admin), golfer].each do |user|
      log_in_as(user)
      expect { delete "/golfer_trips/#{golfer_trip.id}" }.not_to change(GolferTrip, :count)
      expect(response).to redirect_to('/dashboard')
    end
  end

  describe 'the button' do
    it 'renders on the finances page for the site admin only' do
      log_in_as(site_admin)
      get '/finances', params: { trip_id: trip.id }
      expect(response.body).to include('Delete Reservation')

      paid = create(:golfer_trip, trip: trip, is_paid: true, balance: 0)
      get '/finances', params: { trip_id: trip.id }
      expect(response.body.scan('Delete Reservation').length).to eq(2)
      expect(response.body).to include(%(action="/golfer_trips/#{paid.id}"))

      log_in_as(create(:golfer, :admin))
      get '/finances', params: { trip_id: trip.id }
      expect(response.body).not_to include('Delete Reservation')
    end
  end
end
