require 'rails_helper'

# Runs db/seeds/mad_men_walkthrough.rb and db/seeds/mad_men_fill.rb, then walks the
# registration sequence step by step, so the manual walkthrough's numbers are verified.
RSpec.describe 'Registration walkthrough', type: :request do
  def log_in_as(golfer)
    Rack::Attack.cache.store.clear
    post '/login', params: { email: golfer.email, password: 'oldfashioned' }
  end

  # Nights are indexed 0 (Sat) .. 6 (Fri); rounds ride along on the same dates.
  def register(golfer, nights: nil, full: false)
    log_in_as(golfer)
    if full
      post '/register_trip', params: { full_trip: '1', deposit_policy_acknowledged: '1' }
    else
      ids = nights.map { |i| @nights[i].id.to_s }
      round_ids = @trip.rounds.where(date: nights.map { |i| @nights[i].date }).pluck(:id).map(&:to_s)
      post '/register_trip', params: { nights: ids, rounds: round_ids, deposit_policy_acknowledged: '1' }
    end
  end

  def fill(*names)
    allow(ENV).to receive(:fetch).with('NAMES').and_return(names.join(','))
    expect { load Rails.root.join('db/seeds/mad_men_fill.rb') }.to output.to_stdout
  end

  def open_counts
    @trip.reload.open_bed_spots_by_night.map(&:last)
  end

  def registered
    Golfer.where(id: GolferTrip.where(trip: @trip).select(:golfer_id))
  end

  def recipients_without(new_golfer)
    Golfer.where.not(id: registered.select(:id)).where.not(id: @trip.bed_alert_opt_outs.select(:golfer_id)).where.not(id: new_golfer.id)
  end

  # Everyone unregistered and not opted out, minus the golfer whose signup triggers the blast.
  def blast_without(new_golfer)
    have_enqueued_job(BulkMailJob).with('bed_availability', a_collection_containing_exactly(*recipients_without(new_golfer).ids), @trip)
  end

  def rearm
    @trip.update_column(:last_bed_alert_at, nil)
  end

  def bed_in(room_name, description = nil)
    scope = Bed.joins(:bedroom).where(bedrooms: { name: room_name })
    description ? scope.find_by!(description: description) : scope.first!
  end

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:[]).with('WALKTHROUGH_SEED_ALLOW').and_return('1')
    allow(ENV).to receive(:[]).with('CURRENT_TRIP_NUMBER').and_return('XXVII')
    allow(ENV).to receive(:[]).with('SITE_ADMIN_EMAIL').and_return('don@sterlingcooper.com')
    expect { load Rails.root.join('db/seeds/mad_men_walkthrough.rb') }.to output(/Seeded KPC XXVII/).to_stdout

    @trip = Trip.find_by!(number: 'XXVII')
    @nights = @trip.nights.order(:date).to_a
    @don, @roger, @burt, @lane = %w[don roger burt lane].map { |n| Golfer.find_by!(email: "#{n}@sterlingcooper.com") }
    @g = Golfer.default.index_by { |golfer| golfer.first_name.downcase.to_sym }
  end

  it 'behaves as the walkthrough describes, step by step' do
    # --- seeded state: 25 slots, admins already registered and reserved all week, registration closed
    expect(@trip.total_bed_spots).to eq(25)
    expect(@trip.registration_open).to be(false)
    expect(GolferTrip.count).to eq(4)
    admin_trips = GolferTrip.where(golfer: [@don, @roger, @burt, @lane])
    expect(admin_trips.pluck(:cost, :balance, :reserved_all_week).uniq).to eq([[0, 0, true]])
    expect(@don.golfer_nights.count).to eq(5)
    expect(@don.golfer_trips.first.is_full_trip).to be_falsey
    expect([@roger, @burt, @lane].map { |a| a.golfer_trips.first.is_full_trip }).to eq([true, true, true])
    expect(GolferNight.group(:night_id).count.values_at(*@nights.map(&:id))).to eq([3, 3, 4, 4, 4, 4, 4])
    expect(open_counts).to eq([21] * 7)   # all four hold a spot every night, Don's two away nights included

    # --- registration is closed: regular golfers are kept out
    log_in_as(@g[:pete])
    get '/register_trip'
    expect(response).to redirect_to('/dashboard')

    # --- Don opens registration with the dashboard button; no email
    log_in_as(@don)
    get '/dashboard'
    expect(response.body).to include('Open Trip Registration')
    expect { patch "/trips/#{@trip.id}/open_registration" }.not_to change { ActionMailer::Base.deliveries.count }
    expect(@trip.reload.registration_open).to be(true)
    get '/attendance', params: { trip_id: @trip.id }
    expect(response.body).to include('21 of 25 open all week')

    # --- 1. Pete (full trip): first blast, to all 24 other golfers
    expect { register(@g[:pete], full: true) }.to blast_without(@g[:pete])
    expect(open_counts).to eq([20] * 7)
    expect(@g[:pete].golfer_trips.first.reserved_all_week).to be(false)

    # --- Arnold opts out from his email
    post '/bed_alerts/opt_out', params: { token: BedAlertOptOut.token_for(@g[:arnold], @trip) }
    expect(@trip.bed_alert_opt_outs.pluck(:golfer_id)).to eq([@g[:arnold].id])

    # --- 2. Ken (full): inside the hour, so no email
    expect { register(@g[:ken], full: true) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([19] * 7)

    # --- re-arm, 3. Harry Sat-Mon (early leaver): email to 21 (no Arnold)
    rearm
    expect { register(@g[:harry], nights: [0, 1, 2]) }.to blast_without(@g[:harry])
    expect(open_counts).to eq([18, 18, 18, 19, 19, 19, 19])
    expect(recipients_without(@g[:harry]).count).to eq(21)

    # --- 4. Paul Wed-Fri (late arriver) shares Harry's spot; no email
    expect { register(@g[:paul], nights: [4, 5, 6]) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([18, 18, 18, 19, 18, 18, 18])
    expect(@trip.open_bed_spots).to eq(18)   # tightest night; Tuesday's extra spot is not a full-week bed

    # --- 5. Henry Thu-Fri, then Don reserves him all week on /bed_assignments
    register(@g[:henry], nights: [5, 6])
    expect(open_counts).to eq([18, 18, 18, 19, 18, 17, 17])
    henry_trip = @g[:henry].golfer_trips.first
    log_in_as(@don)
    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: admin_trips.pluck(:id).map(&:to_s) + [henry_trip.id.to_s] }
    expect(henry_trip.reload.reserved_all_week).to be(true)
    expect(admin_trips.reload.pluck(:reserved_all_week).uniq).to eq([true])
    expect(open_counts).to eq([17, 17, 17, 18, 17, 17, 17])
    get '/attendance', params: { trip_id: @trip.id }
    expect(response.body).to include('17 of 25 open all week')

    # --- re-arm, 6. Sal (full): email "16 Beds Left" to 18
    rearm
    expect { register(@g[:sal], full: true) }.to blast_without(@g[:sal])
    expect(open_counts).to eq([16, 16, 16, 17, 16, 16, 16])
    expect(recipients_without(@g[:sal]).count).to eq(18)

    # --- 7. fast-forward: 13 golfers registered quietly, no email and no blast
    expect { fill(*%w[freddy duck ted jim bob stan michael greg abe lee jimmy lou bobby]) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([3, 3, 3, 4, 3, 3, 3])
    expect(registered.count).to eq(4 + 6 + 13)

    # --- re-arm, 8. Kurt (full): "2 Beds Left" to the 4 still unregistered and not opted out
    rearm
    expect { register(@g[:kurt], full: true) }.to blast_without(@g[:kurt])
    expect(open_counts).to eq([2, 2, 2, 3, 2, 2, 2])
    expect(recipients_without(@g[:kurt]).map(&:first_name)).to match_array(%w[Joey Ed Smitty Gene])

    # --- re-arm, 9. Joey (full): "1 Bed Left", Tuesday shows 2 open
    rearm
    expect { register(@g[:joey], full: true) }.to blast_without(@g[:joey])
    expect(open_counts).to eq([1, 1, 1, 2, 1, 1, 1])
    mail = GolferMailer.bed_availability(@g[:gene], @trip)
    expect(mail.subject).to eq('KPC XXVII - 1 Bed Left')
    expect(mail.text_part.body.encoded).to include('Tuesday, April 27: 2 open')

    # --- 10. Ed (full): full-week zero. Admin alert AND a forced blast despite the cooldown
    expect { register(@g[:ed], full: true) }
      .to have_enqueued_job(BulkMailJob).with('bed_capacity_reached', a_collection_containing_exactly(@don.id, @roger.id, @burt.id, @lane.id), @trip)
      .and blast_without(@g[:ed])
    expect(open_counts).to eq([0, 0, 0, 1, 0, 0, 0])
    expect(@trip.open_bed_spots).to eq(0)
    alert = GolferMailer.bed_capacity_reached(@don, @trip)
    expect(alert.subject).to eq('KPC XXVII - No Full-Week Beds Left')
    expect(alert.text_part.body.encoded).to include('Tue 4/27 (1)')
    expect(GolferMailer.bed_availability(@g[:gene], @trip).subject).to eq('KPC XXVII - No Full-Week Beds Left')
    log_in_as(@don)
    get '/attendance', params: { trip_id: @trip.id }
    expect(response.body).to include('0 of 25 open all week', 'No full-week beds left')

    # --- 11. Smitty: full-week blocked in the UI and on the server; Tuesday only works
    log_in_as(@g[:smitty])
    get '/register_trip'
    expect(response.body).not_to include('Give me the whole enchilada, bud!')
    expect(response.body.scan('House full').length).to eq(6)
    expect { post '/register_trip', params: { full_trip: '1', deposit_policy_acknowledged: '1' } }.not_to change(GolferTrip, :count)
    expect { post '/register_trip', params: { nights: [@nights[0].id.to_s, @nights[3].id.to_s], deposit_policy_acknowledged: '1' } }
      .not_to change(GolferTrip, :count)
    rearm
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    register(@g[:smitty], nights: [3])
    expect(ActiveJob::Base.queue_adapter.enqueued_jobs.map { |job| job[:args].first }).to eq(['bed_availability'])   # house-full blast, no second admin alert
    expect(open_counts).to eq([0] * 7)
    expect(recipients_without(@g[:smitty]).map(&:first_name)).to eq(['Gene'])
    expect(GolferMailer.bed_availability(@g[:gene], @trip).subject).to eq('KPC XXVII - The House Is Full')

    # --- 12. Gene: nothing is open; an empty submit gets a friendly error, not a 500
    log_in_as(@g[:gene])
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
    get '/attendance', params: { trip_id: @trip.id }
    expect(response.body).to include('0 of 25 open all week', 'No full-week beds left')

    # --- 14. Gene takes the reopened Thu-Fri
    expect { register(@g[:gene], nights: [5, 6]) }.to change(GolferTrip, :count).by(1)
    expect(open_counts).to eq([0] * 7)
    expect(registered.count).to eq(28)   # 28 registered for 25 slots, because partial stays (Harry/Paul, Ken/Gene) share spots

    # --- bed assignments: non-overlapping golfers share a one-person bed; overlapping ones can't
    harry_trip, paul_trip, pete_trip = [:harry, :paul, :pete].map { |n| @g[n].golfer_trips.first }
    ken_trip.reload
    reserved = (admin_trips.pluck(:id) + [henry_trip.id]).map(&:to_s)
    garden = bed_in('Garden Room', 'Queen')
    log_in_as(@don)

    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: reserved, beds: { garden.id.to_s => [harry_trip.id.to_s, paul_trip.id.to_s] } }
    expect([harry_trip, paul_trip].map { |gt| gt.reload.bed_id }).to eq([garden.id] * 2)
    get '/bed_assignments/week', params: { trip_id: @trip.id }
    shared_row = response.body[/<tr>\s*<td class="bed-col">\s*<strong>##{garden.rank}<\/strong>.*?<\/tr>/m]
    expect(shared_row).to include('Harry', 'Paul')   # one one-person bed, Harry Sat-Mon, Paul Wed-Fri
    expect(shared_row.scan('>open</td>').length).to eq(1)   # Tuesday

    sunroom = bed_in('Sunroom', 'Queen')
    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: reserved, beds: { sunroom.id.to_s => [pete_trip.id.to_s, ken_trip.id.to_s] } }
    expect(flash[:error]).to include('already at capacity')
    expect([harry_trip, paul_trip].map { |gt| gt.reload.bed_id }).to eq([garden.id] * 2)   # nothing changed

    primary = bed_in('Primary Suite', 'King')
    ocean = bed_in('Ocean Suite', 'King')
    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: reserved,
                                         beds: { primary.id.to_s => [pete_trip.id.to_s, ken_trip.id.to_s],
                                                 ocean.id.to_s => [@don.golfer_trips.first.id.to_s, @roger.golfer_trips.first.id.to_s],
                                                 garden.id.to_s => [harry_trip.id.to_s, paul_trip.id.to_s] } }
    expect([pete_trip, ken_trip].map { |gt| gt.reload.bed_id }).to eq([primary.id] * 2)
    get '/bed_assignments/week', params: { trip_id: @trip.id }
    expect(response.body.scan('away (reserved)</span>').length).to eq(2)   # Don's Sat and Sun, held for him all week

    twin = bed_in('Twin Room A', 'Twin A')
    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: reserved, beds: { twin.id.to_s => [henry_trip.id.to_s, paul_trip.id.to_s] } }
    expect(flash[:error]).to include('already at capacity')   # Henry is reserved all week, so he overlaps Paul
  end
end
