require 'rails_helper'

RSpec.describe 'Previous trips', type: :request do
  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  let(:admin) { create(:golfer, :admin, nickname: 'don') }
  let(:other_admin) { create(:golfer, :admin, nickname: 'roger') }
  let!(:old_trip) { create(:trip, completed: true, number: 'XXV', year: 2025) }
  let!(:new_trip) { create(:trip, completed: true, number: 'XXVI', year: 2026) }
  let(:regular) { create(:golfer, nickname: 'pete') }

  it 'is for admins only' do
    log_in_as(create(:golfer))
    get '/previous_trips'
    expect(response).to redirect_to('/dashboard')
  end

  describe 'attendance' do
    before do
      # admin and regular went to both trips; a second admin only to the newer one
      [old_trip, new_trip].each { |t| [admin, regular].each { |g| create(:golfer_trip, golfer: g, trip: t) } }
      create(:golfer_trip, golfer: other_admin, trip: new_trip)
      log_in_as(admin)
    end

    it 'counts each trip headcount including admins' do
      get '/previous_trips'
      expect(old_trip.unique_attendance).to eq(2)
      expect(new_trip.unique_attendance).to eq(3)
      expect(response.body.scan('Attendance (unique golfers, committee included)').length).to eq(2)
      expect(response.body).to match(/Attendance \(unique golfers, committee included\)<\/td>\s*<td>3<\/td>/)
      expect(response.body).to match(/Attendance \(unique golfers, committee included\)<\/td>\s*<td>2<\/td>/)
    end

    it 'shows the all-time unique count once per golfer at the top' do
      get '/previous_trips'
      expect(Trip.unique_attendance_across([old_trip, new_trip])).to eq(3)   # not 5
      expect(response.body).to include('3 different golfers across 2 trips')
      expect(response.body.index('3 different golfers')).to be < response.body.index('KPC XXVI')
    end

    it 'shows a headcount even when a trip has no financial summary' do
      get '/previous_trips'
      expect(response.body).to include('No financial summary recorded.')
      expect(response.body).to match(/Attendance \(unique golfers, committee included\)<\/td>\s*<td>3<\/td>/)
    end
  end

  describe 'expenses' do
    before do
      create(:expense, trip: new_trip, golfer: admin, description: 'Rental house', amount: 3000, date: Date.new(2026, 4, 1))
      create(:expense, trip: new_trip, golfer: other_admin, description: 'Trophies', amount: 150, date: Date.new(2026, 4, 20))
      create(:expense, trip: new_trip, golfer: admin, description: 'Beer', amount: 600, date: Date.new(2026, 4, 22))
      create(:expense, trip: old_trip, golfer: admin, description: 'Last year house', amount: 2500)
      log_in_as(admin)
    end

    it 'lists each trip expenses largest first, under the totals' do
      get '/previous_trips'
      body = response.body
      expect(body.index('Rental house')).to be < body.index('Beer')
      expect(body.index('Beer')).to be < body.index('Trophies')
    end

    it 'shows the date and who paid, and the listed total' do
      get '/previous_trips'
      expect(response.body).to include('Apr 1, 2026 - paid by Don', 'Apr 20, 2026 - paid by Roger')
      expect(response.body).to match(/Listed expenses total<\/td>\s*<td>\$3,750<\/td>/)
    end

    it 'keeps each trip to its own expenses' do
      get '/previous_trips'
      expect(response.body.scan('Last year house').length).to eq(1)
      expect(response.body.index('KPC XXVI')).to be < response.body.index('Rental house')
      expect(response.body.index('Rental house')).to be < response.body.index('KPC XXV<')
    end

    it 'says so when a trip has no expenses' do
      get '/previous_trips'
      new_trip.expenses.destroy_all
      get '/previous_trips'
      expect(response.body).to include('No expenses recorded.')
    end

    it 'orders expenses with the same amount by newest date first' do
      create(:expense, trip: new_trip, golfer: admin, description: 'Older tie', amount: 600, date: Date.new(2026, 4, 2))
      get '/previous_trips'
      expect(response.body.index('Beer')).to be < response.body.index('Older tie')
    end
  end
end
