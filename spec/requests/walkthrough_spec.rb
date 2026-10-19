require 'rails_helper'

# Mirrors db/seeds/mad_men_walkthrough.rb step for step, so the manual
# walkthrough's expected numbers are verified.
RSpec.describe 'Registration walkthrough', type: :request do
  def log_in_as(golfer)
    Rack::Attack.cache.store.clear   # this walkthrough logs in far more than the login throttle allows
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  def named(nickname, *traits)
    create(:golfer, *traits, nickname: nickname)
  end

  # Nights are indexed 0 (Sat) .. 6 (Fri); rounds ride along on the same dates.
  def register(golfer, nights: nil, full: false, ack: '1')
    log_in_as(golfer)
    if full
      post '/register_trip', params: { full_trip: '1', deposit_policy_acknowledged: ack }
    else
      ids = nights.map { |i| @nights[i].id.to_s }
      round_ids = @trip.rounds.where(date: nights.map { |i| @nights[i].date }).pluck(:id).map(&:to_s)
      post '/register_trip', params: { nights: ids, rounds: round_ids, deposit_policy_acknowledged: ack }
    end
  end

  def open_counts
    @trip.open_bed_spots_by_night.map(&:last)
  end

  def registered
    Golfer.where(id: GolferTrip.where(trip: @trip).select(:golfer_id))
  end

  # Everyone unregistered and not opted out, minus the golfer whose signup triggers the blast.
  def blast_without(new_golfer)
    ids = Golfer.where.not(id: registered.select(:id)).where.not(id: @trip.bed_alert_opt_outs.select(:golfer_id)).where.not(id: new_golfer.id).ids
    have_enqueued_job(BulkMailJob).with('bed_availability', a_collection_containing_exactly(*ids), @trip)
  end

  before do
    allow(ENV).to receive(:[]).and_call_original
    @trip = create(:trip, :registration_closed, number: 'XXVII', year: 2027, deposit_due_date: Date.new(2027, 1, 1),
                   start_date: Date.new(2027, 4, 24))
    allow(ENV).to receive(:[]).with('CURRENT_TRIP_NUMBER').and_return('XXVII')
    @nights = (0..6).map { |i| create(:night, trip: @trip, date: Date.new(2027, 4, 24) + i, cost: 130) }
    [[25, 0], [26, 0], [27, 80], [28, 80], [29, 80], [30, 80]].each { |d, c| create(:round, trip: @trip, date: Date.new(2027, 4, d), cost: c) }

    house = create(:house, trip: @trip)
    @beds = {}
    [['Primary Suite', [['King', 2, 1]]], ['Ocean Queen', [['Queen', 1, 2]]], ['Garden Queen', [['Queen', 1, 3]]],
     ['Twin Room', [['Twin A', 1, 4], ['Twin B', 1, 5]]], ['Bunk Room', [['Bunk Top', 1, 6], ['Bunk Bottom', 1, 7]]],
     ['Den', [['Shared Queen', 2, 8]]], ['Loft', [['Sofa Bed', 2, 9], ['Air Mattress', 1, 10]]]].each do |room_name, beds|
      room = create(:bedroom, house: house, name: room_name)
      beds.each { |desc, cap, rank| @beds[room_name + desc] = create(:bed, bedroom: room, description: desc, capacity: cap, rank: rank) }
    end
    expect(@trip.total_bed_spots).to eq(13)

    @don, @roger, @burt, @lane = %w[Don Roger Burt Lane].map { |n| named(n, :admin) }
    allow(ENV).to receive(:[]).with('SITE_ADMIN_EMAIL').and_return(@don.email)
    @g = %w[Pete Ken Harry Paul Henry Sal Freddy Duck Ted Jim Bob Stan Michael Greg Abe Lee Jimmy Lou Bobby Arnold Kurt Joey Ed Smitty Gene]
         .map { |n| [n.downcase.to_sym, named(n)] }.to_h
  end

  it 'behaves as the walkthrough describes, step by step' do
    # --- registration is closed: regular golfers are kept out
    log_in_as(@g[:pete])
    get '/register_trip'
    expect(response).to redirect_to('/dashboard')

    # --- admins register first: $0, bed reserved all week. Roger, Burt and Lane attend all week; Don Mon-Fri.
    expect do
      register(@don,   nights: [2, 3, 4, 5, 6])
      register(@roger, full: true)
      register(@burt,  full: true)
      register(@lane,  full: true)
    end.not_to have_enqueued_job(BulkMailJob).with('bed_availability', anything, @trip)
    admin_trips = GolferTrip.where(golfer: [@don, @roger, @burt, @lane])
    expect(admin_trips.pluck(:cost, :balance, :reserved_all_week).uniq).to eq([[0, 0, true]])
    expect(@don.golfer_nights.count).to eq(5)
    expect(@don.golfer_trips.first.is_full_trip).to be_falsey
    expect([@roger, @burt, @lane].map { |a| a.golfer_trips.first.is_full_trip }).to eq([true, true, true])
    expect(GolferNight.where(night: @nights).group(:night_id).count.values_at(*@nights.map(&:id))).to eq([3, 3, 4, 4, 4, 4, 4])
    expect(open_counts).to eq([9] * 7)   # all four hold a spot every night, Don's two away nights included
    log_in_as(@don)
    get "/attendance", params: { trip_id: @trip.id }
    expect(response.body).to include('9 of 13 open all week')

    # --- Don opens registration with the dashboard button; no email
    log_in_as(@don)
    get '/dashboard'
    expect(response.body).to include('Open Trip Registration')
    expect { patch "/trips/#{@trip.id}/open_registration" }.not_to change { ActionMailer::Base.deliveries.count }
    expect(@trip.reload.registration_open).to be(true)

    # --- 1. Pete (full trip): first blast, to all 24 other golfers
    expect { register(@g[:pete], full: true) }.to blast_without(@g[:pete])
    expect(open_counts).to eq([8] * 7)
    expect(@g[:pete].golfer_trips.first.reserved_all_week).to be(false)

    # --- Arnold opts out from his email
    token = BedAlertOptOut.token_for(@g[:arnold], @trip)
    post '/bed_alerts/opt_out', params: { token: token }
    expect(@trip.bed_alert_opt_outs.pluck(:golfer_id)).to eq([@g[:arnold].id])

    # --- 2. Ken (full): inside the hour, so no email
    expect { register(@g[:ken], full: true) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([7] * 7)

    # --- re-arm the cooldown, 3. Harry Sat-Mon (early leaver): email, 21 recipients
    @trip.update_column(:last_bed_alert_at, nil)
    expect { register(@g[:harry], nights: [0, 1, 2]) }.to blast_without(@g[:harry])
    expect(open_counts).to eq([6, 6, 6, 7, 7, 7, 7])
    expect(Golfer.where.not(id: registered.select(:id)).where.not(id: @g[:arnold].id).count).to eq(21)

    # --- 4. Paul Wed-Fri (late arriver): shares Harry's spot; no email
    expect { register(@g[:paul], nights: [4, 5, 6]) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([6, 6, 6, 7, 6, 6, 6])
    expect(@trip.open_bed_spots).to eq(6)   # tightest night; Tuesday's extra spot doesn't count as a full-week bed

    # --- 5. Henry Thu-Fri, then Don reserves him all week on /bed_assignments
    register(@g[:henry], nights: [5, 6])
    expect(open_counts).to eq([6, 6, 6, 7, 6, 5, 5])
    henry_trip = @g[:henry].golfer_trips.first
    log_in_as(@don)
    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: admin_trips.pluck(:id).map(&:to_s) + [henry_trip.id.to_s] }
    expect(henry_trip.reload.reserved_all_week).to be(true)
    expect(admin_trips.reload.pluck(:reserved_all_week).uniq).to eq([true])
    expect(open_counts).to eq([5, 5, 5, 6, 5, 5, 5])
    get "/attendance", params: { trip_id: @trip.id }
    expect(response.body).to include('5 of 13 open all week')

    # --- re-arm, 6. Sal (full): email "4 Beds Left"
    @trip.update_column(:last_bed_alert_at, nil)
    expect { register(@g[:sal], full: true) }.to blast_without(@g[:sal])
    expect(open_counts).to eq([4, 4, 4, 5, 4, 4, 4])

    # --- 7. Freddy, 8. Duck (full): cooldown, no email
    expect { register(@g[:freddy], full: true) }.not_to have_enqueued_job(BulkMailJob)
    expect { register(@g[:duck], full: true) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([2, 2, 2, 3, 2, 2, 2])

    # --- re-arm, 9. Ted (full): "1 Bed Left", Tuesday shows 2 open
    @trip.update_column(:last_bed_alert_at, nil)
    expect { register(@g[:ted], full: true) }.to blast_without(@g[:ted])
    expect(open_counts).to eq([1, 1, 1, 2, 1, 1, 1])
    mail = GolferMailer.bed_availability(@g[:stan], @trip)
    expect(mail.subject).to eq('KPC XXVII - 1 Bed Left')
    expect(mail.text_part.body.encoded).to include('Tuesday, April 27: 2 open')

    # --- 10. Jim (full): full-week zero. Admin alert AND a forced blast despite the cooldown
    expect { register(@g[:jim], full: true) }
      .to have_enqueued_job(BulkMailJob).with('bed_capacity_reached', a_collection_containing_exactly(@don.id, @roger.id, @burt.id, @lane.id), @trip)
      .and blast_without(@g[:jim])
    expect(open_counts).to eq([0, 0, 0, 1, 0, 0, 0])
    expect(@trip.open_bed_spots).to eq(0)
    alert = GolferMailer.bed_capacity_reached(@don, @trip)
    expect(alert.subject).to eq('KPC XXVII - No Full-Week Beds Left')
    expect(alert.text_part.body.encoded).to include('Tue 4/27 (1)')
    expect(GolferMailer.bed_availability(@g[:stan], @trip).subject).to eq('KPC XXVII - No Full-Week Beds Left')

    # --- 11. Bob: full-week blocked in the UI and on the server; Tuesday only works
    log_in_as(@g[:bob])
    get '/register_trip'
    expect(response.body).not_to include('Give me the whole enchilada, bud!')
    expect(response.body.scan('House full').length).to eq(6)
    expect { post '/register_trip', params: { full_trip: '1', deposit_policy_acknowledged: '1' } }.not_to change(GolferTrip, :count)
    expect { post '/register_trip', params: { nights: [@nights[0].id.to_s, @nights[3].id.to_s], deposit_policy_acknowledged: '1' } }
      .not_to change(GolferTrip, :count)
    @trip.update_column(:last_bed_alert_at, nil)
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    register(@g[:bob], nights: [3])
    jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
    expect(jobs.map { |job| job[:args].first }).to eq(['bed_availability'])   # a full-house blast, no second admin alert
    expect(open_counts).to eq([0] * 7)
    expect(GolferMailer.bed_availability(@g[:stan], @trip).subject).to eq('KPC XXVII - The House Is Full')

    # --- 12. Stan: nothing is open; empty submit gets a friendly error, not a 500
    log_in_as(@g[:stan])
    get '/register_trip'
    expect(response.body.scan('House full').length).to eq(7)
    expect { post '/register_trip', params: { deposit_policy_acknowledged: '1' } }.not_to change(GolferTrip, :count)
    expect(flash[:error]).to include('Pick at least one night or round')
    expect { post '/register_trip', params: { nights: [@nights[0].id.to_s], deposit_policy_acknowledged: '1' } }.not_to change(GolferTrip, :count)

    # --- 13. Don trims Ken's stay (drops Thu-Fri): beds reopen on those nights, no email
    ken_trip = @g[:ken].golfer_trips.first
    keep_nights = @nights[0..4].map { |n| n.id.to_s }
    keep_rounds = @trip.rounds.where(date: @nights[0..4].map(&:date)).pluck(:id).map(&:to_s)
    log_in_as(@don)
    expect { patch "/golfer_trips/#{ken_trip.id}", params: { nights: keep_nights, rounds: keep_rounds } }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([0, 0, 0, 0, 0, 1, 1])
    get "/attendance", params: { trip_id: @trip.id }
    expect(response.body).to include('0 of 13 open all week', 'No full-week beds left')

    # --- 14. Stan takes the reopened Thu-Fri
    expect { register(@g[:stan], nights: [5, 6]) }.to change(GolferTrip, :count).by(1)
    expect(open_counts).to eq([0] * 7)

    # --- bed assignments: non-overlapping golfers share a one-person bed; overlapping ones can't
    harry_trip = @g[:harry].golfer_trips.first
    paul_trip = @g[:paul].golfer_trips.first
    pete_trip = @g[:pete].golfer_trips.first
    ken_trip.reload
    reserved = (admin_trips.pluck(:id) + [henry_trip.id]).map(&:to_s)
    log_in_as(@don)
    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: reserved,
                                         beds: { @beds['Ocean QueenQueen'].id.to_s => [harry_trip.id.to_s, paul_trip.id.to_s] } }
    expect([harry_trip, paul_trip].map { |gt| gt.reload.bed_id }).to eq([@beds['Ocean QueenQueen'].id] * 2)
    get "/bed_assignments/week", params: { trip_id: @trip.id }
    shared_row = response.body[/<tr>\s*<td class="bed-col">\s*<strong>#2<\/strong>.*?<\/tr>/m]
    expect(shared_row).to include('Harry', 'Paul')   # one one-person bed, Harry Sat-Mon, Paul Wed-Fri
    expect(shared_row.scan('>open</td>').length).to eq(1)   # Tuesday

    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: reserved,
                                         beds: { @beds['Garden QueenQueen'].id.to_s => [pete_trip.id.to_s, ken_trip.id.to_s] } }
    expect(flash[:error]).to include('already at capacity')
    expect([harry_trip, paul_trip].map { |gt| gt.reload.bed_id }).to eq([@beds['Ocean QueenQueen'].id] * 2)   # nothing changed

    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: reserved,
                                         beds: { @beds['Primary SuiteKing'].id.to_s => [pete_trip.id.to_s, ken_trip.id.to_s] } }
    expect([pete_trip, ken_trip].map { |gt| gt.reload.bed_id }).to eq([@beds['Primary SuiteKing'].id] * 2)

    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: reserved,
                                         beds: { @beds['Twin RoomTwin A'].id.to_s => [henry_trip.id.to_s, paul_trip.id.to_s] } }
    expect(flash[:error]).to include('already at capacity')   # Henry is reserved all week, so he overlaps Paul
  end
end
