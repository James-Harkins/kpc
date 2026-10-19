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
    @trip.bed_alert_recipients.where.not(id: new_golfer.id)
  end

  # Signups no longer email golfers; the weekly rake task does.
  def no_blast
    have_enqueued_job(BulkMailJob).with('bed_availability', anything, @trip)
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
    expect { register(@g[:pete], full: true) }.not_to no_blast
    expect(open_counts).to eq([20] * 7)
    expect(@g[:pete].golfer_trips.first.reserved_all_week).to be(false)

    # --- Arnold opts out from his email
    post '/bed_alerts/opt_out', params: { token: BedAlertOptOut.token_for(@g[:arnold], @trip) }
    expect(@trip.bed_alert_opt_outs.pluck(:golfer_id)).to eq([@g[:arnold].id])

    # --- 2. Ken (full): inside the hour, so no email
    expect { register(@g[:ken], full: true) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([19] * 7)

    # --- re-arm. 3. Harry arrives one night late (Sun-Fri): email goes out BEFORE Don flags him, so Saturday still shows 19
    expect { register(@g[:harry], nights: [1, 2, 3, 4, 5, 6]) }.not_to no_blast
    expect(open_counts).to eq([19, 18, 18, 18, 18, 18, 18])
    expect(recipients_without(@g[:harry]).count).to eq(21)
    harry_trip = @g[:harry].golfer_trips.first
    flagged = admin_trips.pluck(:id).map(&:to_s)
    log_in_as(@don)
    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: flagged + [harry_trip.id.to_s] }
    expect(open_counts).to eq([18] * 7)   # one open night is not worth a bed, so Don holds it all week

    # --- 4. Paul leaves one night early (Sat-Thu): no email, then Don flags him too
    expect { register(@g[:paul], nights: [0, 1, 2, 3, 4, 5]) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([17, 17, 17, 17, 17, 17, 18])
    paul_trip = @g[:paul].golfer_trips.first
    log_in_as(@don)
    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: flagged + [harry_trip.id.to_s, paul_trip.id.to_s] }
    expect(open_counts).to eq([17] * 7)
    expect([harry_trip, paul_trip].map { |gt| gt.reload.reserved_all_week }).to eq([true, true])

    # --- 5-7. A real gap is worth opening: Sal Sat-Mon, Duck Tue-Wed and Henry Thu-Fri share ONE spot, none flagged
    expect { register(@g[:sal], nights: [0, 1, 2]) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([16, 16, 16, 17, 17, 17, 17])
    expect { register(@g[:duck], nights: [3, 4]) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([16, 16, 16, 16, 16, 17, 17])
    expect { register(@g[:henry], nights: [5, 6]) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([16] * 7)
    expect([:sal, :duck, :henry].map { |n| @g[n].golfer_trips.first.reserved_all_week }).to eq([false] * 3)
    log_in_as(@don)
    get '/attendance', params: { trip_id: @trip.id }
    expect(response.body).to include('16 of 25 open all week')

    # --- re-arm, 8. Freddy (full): email "15 Beds Left" to 16
    expect { register(@g[:freddy], full: true) }.not_to no_blast
    expect(open_counts).to eq([15] * 7)
    expect(recipients_without(@g[:freddy]).count).to eq(16)

    # --- 9. fast-forward: 9 golfers registered quietly, no email and no blast
    expect { fill(*%w[ted jim bob stan michael greg abe lee jimmy]) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([6] * 7)
    expect(registered.count).to eq(4 + 8 + 9)

    # --- re-arm, 10. Kurt Sat-Tue: "5 Beds Left" to the 6 still unregistered and not opted out
    expect { register(@g[:kurt], nights: [0, 1, 2, 3]) }.not_to no_blast
    expect(open_counts).to eq([5, 5, 5, 5, 6, 6, 6])
    expect(recipients_without(@g[:kurt]).map(&:first_name)).to match_array(%w[Bobby Lou Joey Ed Smitty Gene])

    # --- 11. Joey Thu-Fri leaves a one-night gap on Wednesday; no email
    expect { register(@g[:joey], nights: [5, 6]) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([5, 5, 5, 5, 6, 5, 5])

    # --- re-arm, 12. Ed (full): "4 Beds Left" to 4, Wednesday shows 5 open
    expect { register(@g[:ed], full: true) }.not_to no_blast
    expect(open_counts).to eq([4, 4, 4, 4, 5, 4, 4])
    expect(recipients_without(@g[:ed]).map(&:first_name)).to match_array(%w[Bobby Lou Smitty Gene])

    # --- 13. Smitty (full), 14. Arnold (opted out of emails, but changes his mind and signs up): no email
    expect { register(@g[:smitty], full: true) }.not_to have_enqueued_job(BulkMailJob)
    expect { register(@g[:arnold], full: true) }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([2, 2, 2, 2, 3, 2, 2])

    # --- re-arm, 15. Gene (full): "1 Bed Left" to Bobby and Lou, Wednesday shows 2 open
    expect { register(@g[:gene], full: true) }.not_to no_blast
    expect(open_counts).to eq([1, 1, 1, 1, 2, 1, 1])
    mail = GolferMailer.bed_availability(@g[:bobby], @trip)
    expect(mail.subject).to eq('KPC XXVII - 1 Bed Left')
    expect(mail.text_part.body.encoded).to include('Wednesday, April 28: 2 open')

    # --- 16. Lou (full): full-week zero. Admin alert, no golfer blast
    expect { register(@g[:lou], full: true) }
      .to have_enqueued_job(BulkMailJob).with('bed_capacity_reached', a_collection_containing_exactly(@don.id, @roger.id, @burt.id, @lane.id), @trip)
    expect(open_counts).to eq([0, 0, 0, 0, 1, 0, 0])
    expect(@trip.open_bed_spots).to eq(0)
    expect(recipients_without(@g[:lou]).map(&:first_name)).to eq(['Bobby'])
    alert = GolferMailer.bed_capacity_reached(@don, @trip)
    expect(alert.subject).to eq('KPC XXVII - No Full-Week Beds Left')
    expect(alert.text_part.body.encoded).to include('Wed 4/28 (1)')
    expect(GolferMailer.bed_availability(@g[:bobby], @trip).subject).to eq('KPC XXVII - No Full-Week Beds Left')
    log_in_as(@don)
    get '/attendance', params: { trip_id: @trip.id }
    expect(response.body).to include('0 of 25 open all week', 'No full-week beds left')

    # --- 17. Bobby: only Wednesday is open. Full week is blocked, an empty submit gets a friendly error, Wednesday works
    log_in_as(@g[:bobby])
    get '/register_trip'
    expect(response.body).not_to include('Give me the whole enchilada, bud!')
    expect(response.body.scan('(House Full)').length).to eq(6)
    expect { post '/register_trip', params: { full_trip: '1', deposit_policy_acknowledged: '1' } }.not_to change(GolferTrip, :count)
    expect { post '/register_trip', params: { nights: [@nights[0].id.to_s, @nights[4].id.to_s], deposit_policy_acknowledged: '1' } }
      .not_to change(GolferTrip, :count)
    expect { post '/register_trip', params: { deposit_policy_acknowledged: '1' } }.not_to change(GolferTrip, :count)
    expect(flash[:error]).to include('Pick at least one night or round')
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    register(@g[:bobby], nights: [4])
    expect(open_counts).to eq([0] * 7)
    expect(ActiveJob::Base.queue_adapter.enqueued_jobs.map { |job| job[:args].first }).to eq([])
    expect(recipients_without(@g[:bobby]).count).to eq(0)
    expect(GolferMailer.bed_availability(@g[:lou], @trip).subject).to eq('KPC XXVII - The House Is Full')
    expect(registered.count).to eq(4 + 25)   # 29 registered for 25 slots, because the stays above share spots

    # --- 18. Don trims Ken's stay (drops Thu-Fri): beds reopen on those nights, no email
    ken_trip = @g[:ken].golfer_trips.first
    keep_nights = @nights[0..4].map { |n| n.id.to_s }
    keep_rounds = @trip.rounds.where(date: @nights[0..4].map(&:date)).pluck(:id).map(&:to_s)
    log_in_as(@don)
    expect { patch "/golfer_trips/#{ken_trip.id}", params: { nights: keep_nights, rounds: keep_rounds } }.not_to have_enqueued_job(BulkMailJob)
    expect(open_counts).to eq([0, 0, 0, 0, 0, 1, 1])
    get '/attendance', params: { trip_id: @trip.id }
    expect(response.body).to include('0 of 25 open all week', 'No full-week beds left')

    # --- bed assignments
    sal_trip, duck_trip, henry_trip, pete_trip = [:sal, :duck, :henry, :pete].map { |n| @g[n].golfer_trips.first }
    ken_trip.reload
    reserved = (admin_trips.pluck(:id) + [harry_trip.id, paul_trip.id]).map(&:to_s)
    garden = bed_in('Garden Room', 'Queen')
    sunroom = bed_in('Sunroom', 'Queen')
    twin = bed_in('Twin Room A', 'Twin A')
    primary = bed_in('Primary Suite', 'King')
    ocean = bed_in('Ocean Suite', 'King')
    log_in_as(@don)

    # Sal, Duck and Henry have no nights in common, so all three fit one one-person bed
    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: reserved, beds: { garden.id.to_s => [sal_trip, duck_trip, henry_trip].map { |gt| gt.id.to_s } } }
    expect([sal_trip, duck_trip, henry_trip].map { |gt| gt.reload.bed_id }).to eq([garden.id] * 3)

    # Harry is reserved all week, so he overlaps Sal on Saturday even though he arrives Sunday
    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: reserved, beds: { sunroom.id.to_s => [harry_trip.id.to_s, sal_trip.id.to_s] } }
    expect(flash[:error]).to include('already at capacity')
    expect([sal_trip, duck_trip, henry_trip].map { |gt| gt.reload.bed_id }).to eq([garden.id] * 3)   # nothing changed

    # Pete and Ken overlap every night, so a one-person bed rejects them
    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: reserved, beds: { sunroom.id.to_s => [pete_trip.id.to_s, ken_trip.id.to_s] } }
    expect(flash[:error]).to include('already at capacity')

    patch '/bed_assignments', params: { trip_id: @trip.id, reserved_all_week: reserved,
                                         beds: { primary.id.to_s => [pete_trip.id.to_s, ken_trip.id.to_s],
                                                 ocean.id.to_s => [@don.golfer_trips.first.id.to_s, @roger.golfer_trips.first.id.to_s],
                                                 garden.id.to_s => [sal_trip, duck_trip, henry_trip].map { |gt| gt.id.to_s },
                                                 sunroom.id.to_s => [harry_trip.id.to_s],
                                                 twin.id.to_s => [paul_trip.id.to_s] } }
    expect([pete_trip, ken_trip].map { |gt| gt.reload.bed_id }).to eq([primary.id] * 2)
    get '/bed_assignments/week', params: { trip_id: @trip.id }
    shared_row = response.body[/<tr>\s*<td class="bed-col">\s*<strong>##{garden.rank}<\/strong>.*?<\/tr>/m]
    expect(shared_row).to include('Sal', 'Duck', 'Henry')   # three golfers, one bed, every night covered
    expect(shared_row.scan('>open</td>').length).to eq(0)
    # held-but-away nights: Don Sat+Sun, Harry Sat, Paul Fri
    expect(response.body.scan('away (reserved)</span>').length).to eq(4)
  end
end
