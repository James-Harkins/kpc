# Admin golfers
@tony = Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'T', email: 'tony@sopranoenterprisesnj.com', password: 'badabing1', password_confirmation: 'badabing1', role: :admin, t_shirt_size: :xl)
@silvio = Golfer.create!(first_name: 'Silvio', last_name: 'Dante', nickname: 'Sil', email: 'silvio@badabing.com', password: 'badabing5', password_confirmation: 'badabing5', role: :admin, t_shirt_size: :l)
@paulie = Golfer.create!(first_name: 'Paulie', last_name: 'Gualtieri', nickname: 'Walnuts', email: 'paulie@gualtieri.net', password: 'badabing3', password_confirmation: 'badabing3', role: :admin, t_shirt_size: :l)

@trip_1 = Trip.create!(year: 2013, number: 'XIII', location: 'Dewey Beach',     start_date: Date.parse('2013-04-21'))
@trip_2 = Trip.create!(year: 2014, number: 'XIV',  location: 'Rehoboth Beach', start_date: Date.parse('2014-04-20'))
@trip_3 = Trip.create!(year: 2015, number: 'XV',   location: 'VA Beach',       start_date: Date.parse('2015-04-19'))
@trip_4 = Trip.create!(year: 2016, number: 'XVI',  location: 'VA Beach',       start_date: Date.parse('2016-04-24'))

@night_1_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-21'), cost: 70)
@night_2_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-22'), cost: 70)
@night_3_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-23'), cost: 70)
@night_4_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-24'), cost: 70)
@night_5_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-25'), cost: 70)
@night_6_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-26'), cost: 70)
@night_7_trip_1 = @trip_1.nights.create!(date: Date.parse('2013-04-27'), cost: 70)

@night_1_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-20'), cost: 70)
@night_2_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-21'), cost: 80)
@night_3_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-22'), cost: 80)
@night_4_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-23'), cost: 80)
@night_5_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-24'), cost: 80)
@night_6_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-25'), cost: 80)
@night_7_trip_2 = @trip_2.nights.create!(date: Date.parse('2014-04-26'), cost: 80)

@night_1_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-19'), cost: 70)
@night_2_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-20'), cost: 90)
@night_3_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-21'), cost: 90)
@night_4_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-22'), cost: 90)
@night_5_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-23'), cost: 90)
@night_6_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-24'), cost: 90)
@night_7_trip_3 = @trip_3.nights.create!(date: Date.parse('2015-04-25'), cost: 90)

@night_1_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-24'), cost: 0)
@night_2_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-25'), cost: 0)
@night_3_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-26'), cost: 100)
@night_4_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-27'), cost: 100)
@night_5_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-28'), cost: 100)
@night_6_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-29'), cost: 100)
@night_7_trip_4 = @trip_4.nights.create!(date: Date.parse('2016-04-30'), cost: 100)

@trip_1_course_1 = @trip_1.rounds.create!(date: Date.parse('2013-04-22'), cost: 0)
@trip_1_course_2 = @trip_1.rounds.create!(date: Date.parse('2013-04-23'), cost: 0)
@trip_1_course_3 = @trip_1.rounds.create!(date: Date.parse('2013-04-24'), cost: 65)
@trip_1_course_4 = @trip_1.rounds.create!(date: Date.parse('2013-04-25'), cost: 65)
@trip_1_course_5 = @trip_1.rounds.create!(date: Date.parse('2013-04-26'), cost: 65)
@trip_1_course_6 = @trip_1.rounds.create!(date: Date.parse('2013-04-27'), cost: 65)

@trip_2_course_1 = @trip_2.rounds.create!(date: Date.parse('2014-04-21'), cost: 0)
@trip_2_course_2 = @trip_2.rounds.create!(date: Date.parse('2014-04-22'), cost: 0)
@trip_2_course_3 = @trip_2.rounds.create!(date: Date.parse('2014-04-23'), cost: 70)
@trip_2_course_4 = @trip_2.rounds.create!(date: Date.parse('2014-04-24'), cost: 70)
@trip_2_course_5 = @trip_2.rounds.create!(date: Date.parse('2014-04-25'), cost: 70)
@trip_2_course_6 = @trip_2.rounds.create!(date: Date.parse('2014-04-26'), cost: 70)

@trip_3_course_2 = @trip_3.rounds.create!(date: Date.parse('2015-04-20'), cost: 0)
@trip_3_course_1 = @trip_3.rounds.create!(date: Date.parse('2015-04-21'), cost: 0)
@trip_3_course_3 = @trip_3.rounds.create!(date: Date.parse('2015-04-22'), cost: 50)
@trip_3_course_4 = @trip_3.rounds.create!(date: Date.parse('2015-04-23'), cost: 50)
@trip_3_course_5 = @trip_3.rounds.create!(date: Date.parse('2015-04-24'), cost: 50)
@trip_3_course_6 = @trip_3.rounds.create!(date: Date.parse('2015-04-25'), cost: 50)

@trip_4_course_1 = @trip_4.rounds.create!(date: Date.parse('2016-04-25'), cost: 00)
@trip_4_course_2 = @trip_4.rounds.create!(date: Date.parse('2016-04-26'), cost: 00)
@trip_4_course_3 = @trip_4.rounds.create!(date: Date.parse('2016-04-27'), cost: 00)
@trip_4_course_4 = @trip_4.rounds.create!(date: Date.parse('2016-04-28'), cost: 00)
@trip_4_course_5 = @trip_4.rounds.create!(date: Date.parse('2016-04-29'), cost: 00)
@trip_4_course_6 = @trip_4.rounds.create!(date: Date.parse('2016-04-30'), cost: 00)

@tony_trip_1 = @tony.golfer_trips.create!(trip: @trip_1)
@tony_trip_1_night_1 = @tony.golfer_nights.create!(night: @night_3_trip_1)
@tony_trip_1_golfer_round_1 = @tony.golfer_rounds.create!(round: @trip_1_course_3)
@tony_trip_1_night_2 = @tony.golfer_nights.create!(night: @night_4_trip_1)
@tony_trip_1_golfer_round_2 = @tony.golfer_rounds.create!(round: @trip_1_course_4)
@tony_trip_1_night_3 = @tony.golfer_nights.create!(night: @night_5_trip_1)
@tony_trip_1_golfer_round_3 = @tony.golfer_rounds.create!(round: @trip_1_course_5)
@tony_trip_1_night_4 = @tony.golfer_nights.create!(night: @night_6_trip_1)
@tony_trip_1_golfer_round_4 = @tony.golfer_rounds.create!(round: @trip_1_course_6)
@tony_trip_1_night_5 = @tony.golfer_nights.create!(night: @night_7_trip_1)

@tony_trip_2 = @tony.golfer_trips.create!(trip: @trip_2)
@tony_trip_2_night_1 = @tony.golfer_nights.create!(night: @night_4_trip_2)
@tony_trip_2_golfer_round_1 = @tony.golfer_rounds.create!(round: @trip_2_course_4)
@tony_trip_2_night_2 = @tony.golfer_nights.create!(night: @night_5_trip_2)
@tony_trip_2_golfer_round_2 = @tony.golfer_rounds.create!(round: @trip_2_course_5)
@tony_trip_2_night_3 = @tony.golfer_nights.create!(night: @night_6_trip_2)
@tony_trip_2_golfer_round_3 = @tony.golfer_rounds.create!(round: @trip_2_course_6)
@tony_trip_2_night_4 = @tony.golfer_nights.create!(night: @night_7_trip_2)

@tony_trip_3 = @tony.golfer_trips.create!(trip: @trip_4)
@tony_trip_3_night_1 = @tony.golfer_nights.create!(night: @night_1_trip_4)
@tony_trip_3_golfer_round_1 = @tony.golfer_rounds.create!(round: @trip_4_course_1)
@tony_trip_3_night_2 = @tony.golfer_nights.create!(night: @night_2_trip_4)
@tony_trip_3_golfer_round_2 = @tony.golfer_rounds.create!(round: @trip_4_course_2)
@tony_trip_3_night_3 = @tony.golfer_nights.create!(night: @night_3_trip_4)
@tony_trip_3_golfer_round_3 = @tony.golfer_rounds.create!(round: @trip_4_course_3)
@tony_trip_3_night_4 = @tony.golfer_nights.create!(night: @night_4_trip_4)
@tony_trip_3_golfer_round_4 = @tony.golfer_rounds.create!(round: @trip_4_course_4)
@tony_trip_3_night_5 = @tony.golfer_nights.create!(night: @night_5_trip_4)
@tony_trip_3_golfer_round_5 = @tony.golfer_rounds.create!(round: @trip_4_course_5)
@tony_trip_3_night_6 = @tony.golfer_nights.create!(night: @night_6_trip_4)
@tony_trip_3_golfer_round_6 = @tony.golfer_rounds.create!(round: @trip_4_course_6)
@tony_trip_3_night_7 = @tony.golfer_nights.create!(night: @night_7_trip_4)

@silvio_trip_1 = @silvio.golfer_trips.create!(trip: @trip_1)
@silvio_trip_1_night_1 = @silvio.golfer_nights.create!(night: @night_5_trip_1)
@silvio_trip_1_golfer_round_1 = @silvio.golfer_rounds.create!(round: @trip_1_course_5)
@silvio_trip_1_night_2 = @silvio.golfer_nights.create!(night: @night_6_trip_1)
@silvio_trip_1_golfer_round_2 = @silvio.golfer_rounds.create!(round: @trip_1_course_6)
@silvio_trip_1_night_3 = @silvio.golfer_nights.create!(night: @night_7_trip_1)

@silvio_trip_2 = @silvio.golfer_trips.create!(trip: @trip_3)
@silvio_trip_2_night_1 = @silvio.golfer_nights.create!(night: @night_5_trip_3)
@silvio_trip_2_golfer_round_1 = @silvio.golfer_rounds.create!(round: @trip_3_course_5)
@silvio_trip_2_night_2 = @silvio.golfer_nights.create!(night: @night_6_trip_3)
@silvio_trip_2_golfer_round_2 = @silvio.golfer_rounds.create!(round: @trip_3_course_6)
@silvio_trip_2_night_3 = @silvio.golfer_nights.create!(night: @night_7_trip_3)

@trip_5 = Trip.create!(year: 2026, number: 'XXVI', location: 'VA Beach', start_date: Date.parse('2026-10-17'))
@night_1_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-10-17'), cost: 120)
@night_2_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-10-18'), cost: 120)
@night_3_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-10-19'), cost: 120)
@night_4_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-10-20'), cost: 120)
@night_5_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-10-21'), cost: 120)
@night_6_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-10-22'), cost: 120)
@night_7_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-10-23'), cost: 120)

# Trip 5 courses — one per round day, with tee times.
# The last three rounds (Oct 21–23) are tournament rounds.
@red_wing      = Course.create!(name: 'Red Wing Lake Golf Course',    address: '1144 Prosperity Rd, Virginia Beach, VA 23451')
@hells_point   = Course.create!(name: "Hell's Point Golf Club",       address: '2700 Atwoodtown Rd, Virginia Beach, VA 23456')
@heron_ridge   = Course.create!(name: 'Heron Ridge Golf Club',        address: '2973 Heron Ridge Dr, Virginia Beach, VA 23456')
@va_beach_natl = Course.create!(name: 'Virginia Beach National',      address: '2500 Tournament Dr, Virginia Beach, VA 23456')
@bow_creek     = Course.create!(name: 'Bow Creek Golf Course',        address: '3425 Clubhouse Rd, Virginia Beach, VA 23452')
@stumpy_lake   = Course.create!(name: 'Stumpy Lake Golf Course',      address: '4797 Indian River Rd, Virginia Beach, VA 23456')

@trip_5_course_1 = @trip_5.rounds.create!(date: Date.parse('2026-10-18'), cost: 0,  course: @red_wing,      tee_time: '10:30 AM')
@trip_5_course_2 = @trip_5.rounds.create!(date: Date.parse('2026-10-19'), cost: 0,  course: @bow_creek,     tee_time: '10:00 AM')
@trip_5_course_3 = @trip_5.rounds.create!(date: Date.parse('2026-10-20'), cost: 75, course: @stumpy_lake,   tee_time: '9:30 AM')
@trip_5_course_4 = @trip_5.rounds.create!(date: Date.parse('2026-10-21'), cost: 75, course: @heron_ridge,   tee_time: '9:00 AM', is_tournament_round: true)
@trip_5_course_5 = @trip_5.rounds.create!(date: Date.parse('2026-10-22'), cost: 75, course: @hells_point,   tee_time: '8:30 AM', is_tournament_round: true)
@trip_5_course_6 = @trip_5.rounds.create!(date: Date.parse('2026-10-23'), cost: 75, course: @va_beach_natl, tee_time: '8:00 AM', is_tournament_round: true)

# ---------------------------------------------------------------------------
# Sopranos golfers — 15 trip 5 registrations
#
# Trip 5 costs (full trip):
#   7 nights × $120 = $840, 6 rounds = $0+$0+$75+$75+$75+$75 = $300
#   Gross = $1,140 — first night discount ($120) = $1,020 net
#
# Night → round mapping (sequential logic):
#   Stay night Oct N, wake up and play round Oct N+1
#   Night 1 (Oct 17) → Round 1 (Oct 18)
#   Night 2 (Oct 18) → Round 2 (Oct 19)
#   Night 3 (Oct 19) → Round 3 (Oct 20)
#   Night 4 (Oct 20) → Round 4 (Oct 21)
#   Night 5 (Oct 21) → Round 5 (Oct 22)
#   Night 6 (Oct 22) → Round 6 (Oct 23)
#   Night 7 (Oct 23) → depart, no round
# ---------------------------------------------------------------------------

# --- 8 full trips (all 7 nights + all 6 rounds, cost $1,020) ---

# 1. Feech La Manna — full trip, paid in full
@feech = Golfer.create!(
  first_name: 'Feech', last_name: 'La Manna', nickname: 'Feech',
  email: 'feech@lamanna.com',
  password: 'badabing16', password_confirmation: 'badabing16',
  t_shirt_size: :xl
)
@feech_trip = @feech.golfer_trips.create!(trip: @trip_5, is_full_trip: true, cost: 1020, balance: 0, is_paid: true)
[@night_1_trip_5, @night_2_trip_5, @night_3_trip_5, @night_4_trip_5, @night_5_trip_5, @night_6_trip_5, @night_7_trip_5].each { |n| @feech.golfer_nights.create!(night: n) }
[@trip_5_course_1, @trip_5_course_2, @trip_5_course_3, @trip_5_course_4, @trip_5_course_5, @trip_5_course_6].each { |r| @feech.golfer_rounds.create!(round: r) }
@feech_trip.payments.create!(amount: 1020)

# 2. Christopher Moltisanti — full trip, paid in two installments
@christopher = Golfer.create!(
  first_name: 'Christopher', last_name: 'Moltisanti', nickname: 'Chrissy',
  email: 'chris@discretewaste.com',
  password: 'badabing2', password_confirmation: 'badabing2',
  t_shirt_size: :m
)
@christopher_trip = @christopher.golfer_trips.create!(trip: @trip_5, is_full_trip: true, cost: 1020, balance: 0, is_paid: true)
[@night_1_trip_5, @night_2_trip_5, @night_3_trip_5, @night_4_trip_5, @night_5_trip_5, @night_6_trip_5, @night_7_trip_5].each { |n| @christopher.golfer_nights.create!(night: n) }
[@trip_5_course_1, @trip_5_course_2, @trip_5_course_3, @trip_5_course_4, @trip_5_course_5, @trip_5_course_6].each { |r| @christopher.golfer_rounds.create!(round: r) }
@christopher_trip.payments.create!(amount: 500)
@christopher_trip.payments.create!(amount: 520)

# 3. Eugene Pontecorvo — full trip, partially paid
@eugene = Golfer.create!(
  first_name: 'Eugene', last_name: 'Pontecorvo', nickname: 'Eugene',
  email: 'eugene@pontecorvo.net',
  password: 'badabing17', password_confirmation: 'badabing17',
  t_shirt_size: :m
)
@eugene_trip = @eugene.golfer_trips.create!(trip: @trip_5, is_full_trip: true, cost: 1020, balance: 420, is_paid: false)
[@night_1_trip_5, @night_2_trip_5, @night_3_trip_5, @night_4_trip_5, @night_5_trip_5, @night_6_trip_5, @night_7_trip_5].each { |n| @eugene.golfer_nights.create!(night: n) }
[@trip_5_course_1, @trip_5_course_2, @trip_5_course_3, @trip_5_course_4, @trip_5_course_5, @trip_5_course_6].each { |r| @eugene.golfer_rounds.create!(round: r) }
@eugene_trip.payments.create!(amount: 600)

# 4. Bobby Baccalieri — full trip, paid in three installments
@bobby = Golfer.create!(
  first_name: 'Bobby', last_name: 'Baccalieri', nickname: 'Bacala',
  email: 'bobby@northjerseymodelrailroad.com',
  password: 'badabing4', password_confirmation: 'badabing4',
  t_shirt_size: :xxl
)
@bobby_trip = @bobby.golfer_trips.create!(trip: @trip_5, is_full_trip: true, cost: 1020, balance: 0, is_paid: true)
[@night_1_trip_5, @night_2_trip_5, @night_3_trip_5, @night_4_trip_5, @night_5_trip_5, @night_6_trip_5, @night_7_trip_5].each { |n| @bobby.golfer_nights.create!(night: n) }
[@trip_5_course_1, @trip_5_course_2, @trip_5_course_3, @trip_5_course_4, @trip_5_course_5, @trip_5_course_6].each { |r| @bobby.golfer_rounds.create!(round: r) }
@bobby_trip.payments.create!(amount: 300)
@bobby_trip.payments.create!(amount: 400)
@bobby_trip.payments.create!(amount: 320)

# 5. Vito Spatafore — full trip, not yet paid
@vito = Golfer.create!(
  first_name: 'Vito', last_name: 'Spatafore', nickname: 'Vito',
  email: 'vito@spatafore.net',
  password: 'badabing18', password_confirmation: 'badabing18',
  t_shirt_size: :xl
)
@vito_trip = @vito.golfer_trips.create!(trip: @trip_5, is_full_trip: true, cost: 1020, balance: 1020, is_paid: false)
[@night_1_trip_5, @night_2_trip_5, @night_3_trip_5, @night_4_trip_5, @night_5_trip_5, @night_6_trip_5, @night_7_trip_5].each { |n| @vito.golfer_nights.create!(night: n) }
[@trip_5_course_1, @trip_5_course_2, @trip_5_course_3, @trip_5_course_4, @trip_5_course_5, @trip_5_course_6].each { |r| @vito.golfer_rounds.create!(round: r) }

# 6. Salvatore Bonpensiero — full trip, overpaid then returned
#    Paid $1,100, return of $80 issued → net paid $1,020, balance $0
@sal = Golfer.create!(
  first_name: 'Salvatore', last_name: 'Bonpensiero', nickname: 'Big Pussy',
  email: 'sal@bonpensiero.com',
  password: 'badabing6', password_confirmation: 'badabing6',
  t_shirt_size: :xxl
)
@sal_trip = @sal.golfer_trips.create!(trip: @trip_5, is_full_trip: true, cost: 1020, balance: 0, is_paid: true)
[@night_1_trip_5, @night_2_trip_5, @night_3_trip_5, @night_4_trip_5, @night_5_trip_5, @night_6_trip_5, @night_7_trip_5].each { |n| @sal.golfer_nights.create!(night: n) }
[@trip_5_course_1, @trip_5_course_2, @trip_5_course_3, @trip_5_course_4, @trip_5_course_5, @trip_5_course_6].each { |r| @sal.golfer_rounds.create!(round: r) }
@sal_trip.payments.create!(amount: 1100)
@sal_trip.payments.create!(amount: -80)

# 7. Carlo Gervasi — full trip, paid in full
@carlo = Golfer.create!(
  first_name: 'Carlo', last_name: 'Gervasi', nickname: 'Carlo',
  email: 'carlo@gervasi.net',
  password: 'badabing19', password_confirmation: 'badabing19',
  t_shirt_size: :l
)
@carlo_trip = @carlo.golfer_trips.create!(trip: @trip_5, is_full_trip: true, cost: 1020, balance: 0, is_paid: true)
[@night_1_trip_5, @night_2_trip_5, @night_3_trip_5, @night_4_trip_5, @night_5_trip_5, @night_6_trip_5, @night_7_trip_5].each { |n| @carlo.golfer_nights.create!(night: n) }
[@trip_5_course_1, @trip_5_course_2, @trip_5_course_3, @trip_5_course_4, @trip_5_course_5, @trip_5_course_6].each { |r| @carlo.golfer_rounds.create!(round: r) }
@carlo_trip.payments.create!(amount: 1020)

# 8. Corrado Soprano — full trip, barely started paying
@junior = Golfer.create!(
  first_name: 'Corrado', last_name: 'Soprano', nickname: 'Junior',
  email: 'corrado@soprano.com',
  password: 'badabing8', password_confirmation: 'badabing8',
  t_shirt_size: :m
)
@junior_trip = @junior.golfer_trips.create!(trip: @trip_5, is_full_trip: true, cost: 1020, balance: 620, is_paid: false)
[@night_1_trip_5, @night_2_trip_5, @night_3_trip_5, @night_4_trip_5, @night_5_trip_5, @night_6_trip_5, @night_7_trip_5].each { |n| @junior.golfer_nights.create!(night: n) }
[@trip_5_course_1, @trip_5_course_2, @trip_5_course_3, @trip_5_course_4, @trip_5_course_5, @trip_5_course_6].each { |r| @junior.golfer_rounds.create!(round: r) }
@junior_trip.payments.create!(amount: 200)
@junior_trip.payments.create!(amount: 200)

# --- 7 partial trips (all sequential stays) ---

# 9. Ralph Cifaretto — arrives Thu (night 4, Oct 20), departs Sun (after night 7, Oct 23)
#    Nights 4-7 ($480) + Rounds 4-6 ($225) = $705, paid in full
@ralph = Golfer.create!(
  first_name: 'Ralph', last_name: 'Cifaretto', nickname: 'Ralphie',
  email: 'ralph@cifarettoconstruction.com',
  password: 'badabing9', password_confirmation: 'badabing9',
  t_shirt_size: :l
)
@ralph_trip = @ralph.golfer_trips.create!(trip: @trip_5, is_full_trip: false, cost: 705, balance: 0, is_paid: true)
[@night_4_trip_5, @night_5_trip_5, @night_6_trip_5, @night_7_trip_5].each { |n| @ralph.golfer_nights.create!(night: n) }
[@trip_5_course_4, @trip_5_course_5, @trip_5_course_6].each { |r| @ralph.golfer_rounds.create!(round: r) }
@ralph_trip.payments.create!(amount: 705)

# 10. Richard Aprile — arrives Sat (night 1, Oct 17), departs Tue (after night 3, Oct 19)
#     Nights 1-3 ($360) + Rounds 1-2 ($0) = $360, partially paid
@richie = Golfer.create!(
  first_name: 'Richard', last_name: 'Aprile', nickname: 'Richie',
  email: 'richie@aprile.net',
  password: 'badabing10', password_confirmation: 'badabing10',
  t_shirt_size: :m
)
@richie_trip = @richie.golfer_trips.create!(trip: @trip_5, is_full_trip: false, cost: 360, balance: 160, is_paid: false)
[@night_1_trip_5, @night_2_trip_5, @night_3_trip_5].each { |n| @richie.golfer_nights.create!(night: n) }
[@trip_5_course_1, @trip_5_course_2].each { |r| @richie.golfer_rounds.create!(round: r) }
@richie_trip.payments.create!(amount: 200)

# 11. John Sacrimoni — arrives Sun (night 2, Oct 18), departs Fri (after night 6, Oct 22)
#     Nights 2-6 ($600) + Rounds 2-5 ($225) = $825, paid in full
@johnny = Golfer.create!(
  first_name: 'John', last_name: 'Sacrimoni', nickname: 'Johnny Sack',
  email: 'john@lupertazzifamily.com',
  password: 'badabing11', password_confirmation: 'badabing11',
  t_shirt_size: :xl
)
@johnny_trip = @johnny.golfer_trips.create!(trip: @trip_5, is_full_trip: false, cost: 825, balance: 0, is_paid: true)
[@night_2_trip_5, @night_3_trip_5, @night_4_trip_5, @night_5_trip_5, @night_6_trip_5].each { |n| @johnny.golfer_nights.create!(night: n) }
[@trip_5_course_2, @trip_5_course_3, @trip_5_course_4, @trip_5_course_5].each { |r| @johnny.golfer_rounds.create!(round: r) }
@johnny_trip.payments.create!(amount: 825)

# 12. Phil Leotardo — arrives Mon (night 3, Oct 19), departs Thu (after night 5, Oct 21)
#     Nights 3-5 ($360) + Rounds 3-4 ($150) = $510, not paid
@phil = Golfer.create!(
  first_name: 'Phil', last_name: 'Leotardo', nickname: 'Phil',
  email: 'phil@leotardo.com',
  password: 'badabing12', password_confirmation: 'badabing12',
  t_shirt_size: :l
)
@phil_trip = @phil.golfer_trips.create!(trip: @trip_5, is_full_trip: false, cost: 510, balance: 510, is_paid: false)
[@night_3_trip_5, @night_4_trip_5, @night_5_trip_5].each { |n| @phil.golfer_nights.create!(night: n) }
[@trip_5_course_3, @trip_5_course_4].each { |r| @phil.golfer_rounds.create!(round: r) }

# 13. Herman Rabkin — just the opening weekend (nights 1-2, Oct 17-18), round 1 only
#     Nights 1-2 ($240) + Round 1 ($0) = $240, paid in full
@hesh = Golfer.create!(
  first_name: 'Herman', last_name: 'Rabkin', nickname: 'Hesh',
  email: 'hesh@jfkblvdsound.com',
  password: 'badabing13', password_confirmation: 'badabing13',
  t_shirt_size: :xl
)
@hesh_trip = @hesh.golfer_trips.create!(trip: @trip_5, is_full_trip: false, cost: 240, balance: 0, is_paid: true)
[@night_1_trip_5, @night_2_trip_5].each { |n| @hesh.golfer_nights.create!(night: n) }
@hesh.golfer_rounds.create!(round: @trip_5_course_1)
@hesh_trip.payments.create!(amount: 240)

# 14. Arthur Bucco — late arrival, Wed through end (nights 5-7, Oct 21-23), rounds 5-6
#     Nights 5-7 ($360) + Rounds 5-6 ($150) = $510, partially paid
@artie = Golfer.create!(
  first_name: 'Arthur', last_name: 'Bucco', nickname: 'Artie',
  email: 'artie@vesuvio.com',
  password: 'badabing14', password_confirmation: 'badabing14',
  t_shirt_size: :m
)
@artie_trip = @artie.golfer_trips.create!(trip: @trip_5, is_full_trip: false, cost: 510, balance: 210, is_paid: false)
[@night_5_trip_5, @night_6_trip_5, @night_7_trip_5].each { |n| @artie.golfer_nights.create!(night: n) }
[@trip_5_course_5, @trip_5_course_6].each { |r| @artie.golfer_rounds.create!(round: r) }
@artie_trip.payments.create!(amount: 300)

# 15. Jimmy Altieri — Sun through Tue (nights 2-4, Oct 18-20), rounds 2-3
#     Nights 2-4 ($360) + Rounds 2-3 ($75) = $435, paid in full
@jimmy = Golfer.create!(
  first_name: 'Jimmy', last_name: 'Altieri', nickname: 'Jimmy',
  email: 'jimmy@altieri.net',
  password: 'badabing20', password_confirmation: 'badabing20',
  t_shirt_size: :m
)
@jimmy_trip = @jimmy.golfer_trips.create!(trip: @trip_5, is_full_trip: false, cost: 435, balance: 0, is_paid: true)
[@night_2_trip_5, @night_3_trip_5, @night_4_trip_5].each { |n| @jimmy.golfer_nights.create!(night: n) }
[@trip_5_course_2, @trip_5_course_3].each { |r| @jimmy.golfer_rounds.create!(round: r) }
@jimmy_trip.payments.create!(amount: 435)

# ---------------------------------------------------------------------------
# Tournament scoring — Trip 5 (XXVI)
#
# Rounds 4 (Oct 21), 5 (Oct 22), and 6 (Oct 23) are tournament rounds.
# Rounds 1–3 are scoring rounds used to rank players before team generation.
# (Scores also exist on round 4, but tournament rounds are excluded from
# ranking — so Ralph, whose only scored round is round 4, falls back to
# prior-trip history / no-history handling just like Artie.)
#
# Tournament participants (golfers in rounds 5 and/or 6):
#   Full-trip (8): Feech, Christopher, Eugene, Bobby, Vito, Sal, Carlo, Junior
#   Partial:       Ralph (rounds 4–6), Artie (rounds 5–6)
#
# Artie has no non-tournament rounds this trip → demonstrates "no history" fallback.
#
# To use Trip 5 as the current trip, set in config/application.yml:
#   CURRENT_TRIP_NUMBER: "XXVI"
# ---------------------------------------------------------------------------

def set_score(golfer, round, score)
  GolferRound.find_by!(golfer: golfer, round: round).update!(score: score)
end

# Round 1 (Oct 18) — full-trip golfers, Richie, Hesh
set_score(@feech,       @trip_5_course_1, 74)
set_score(@christopher, @trip_5_course_1, 80)
set_score(@eugene,      @trip_5_course_1, 84)
set_score(@bobby,       @trip_5_course_1, 88)
set_score(@vito,        @trip_5_course_1, 92)
set_score(@sal,         @trip_5_course_1, 96)
set_score(@carlo,       @trip_5_course_1, 99)
set_score(@junior,      @trip_5_course_1, 103)

# Round 2 (Oct 19) — full-trip golfers, Richie, Johnny, Jimmy
set_score(@feech,       @trip_5_course_2, 72)
set_score(@christopher, @trip_5_course_2, 78)
set_score(@eugene,      @trip_5_course_2, 86)
set_score(@bobby,       @trip_5_course_2, 90)
set_score(@vito,        @trip_5_course_2, 94)
set_score(@sal,         @trip_5_course_2, 98)
set_score(@carlo,       @trip_5_course_2, 101)
set_score(@junior,      @trip_5_course_2, 105)
set_score(@johnny,      @trip_5_course_2, 87)

# Round 3 (Oct 20) — full-trip golfers, Phil, Johnny, Jimmy
set_score(@feech,       @trip_5_course_3, 76)
set_score(@christopher, @trip_5_course_3, 82)
set_score(@eugene,      @trip_5_course_3, 83)
set_score(@bobby,       @trip_5_course_3, 87)
set_score(@vito,        @trip_5_course_3, 90)
set_score(@sal,         @trip_5_course_3, 95)
set_score(@carlo,       @trip_5_course_3, 100)
set_score(@junior,      @trip_5_course_3, 102)
set_score(@johnny,      @trip_5_course_3, 88)

# Round 4 (Oct 21) — full-trip golfers, Ralph, Phil, Johnny
set_score(@feech,       @trip_5_course_4, 75)
set_score(@christopher, @trip_5_course_4, 79)
set_score(@eugene,      @trip_5_course_4, 85)
set_score(@bobby,       @trip_5_course_4, 91)
set_score(@vito,        @trip_5_course_4, 93)
set_score(@sal,         @trip_5_course_4, 97)
set_score(@carlo,       @trip_5_course_4, 98)
set_score(@junior,      @trip_5_course_4, 106)
set_score(@ralph,       @trip_5_course_4, 94)

# Admin registrations for Trip 5 — zero cost (committee members)
# Tony is intentionally left unregistered to test the register flow in dev
[@silvio, @paulie].each do |admin|
  admin.golfer_trips.create!(trip: @trip_5, is_full_trip: true, cost: 0, balance: 0, is_paid: true)
  [@night_1_trip_5, @night_2_trip_5, @night_3_trip_5, @night_4_trip_5,
   @night_5_trip_5, @night_6_trip_5, @night_7_trip_5].each { |n| admin.golfer_nights.create!(night: n) }
  [@trip_5_course_1, @trip_5_course_2, @trip_5_course_3, @trip_5_course_4,
   @trip_5_course_5, @trip_5_course_6].each { |r| admin.golfer_rounds.create!(round: r) }
end

# ---------------------------------------------------------------------------
# Bed assignment feature — Trip 5 (XXVI)
#
# Deposit deadline: Jun 15, 2026. Deposit = 50% of golfer_trip cost, derived
# from the payments ledger. Payments below are backdated to spread golfers
# across the three priority tiers:
#
#   Tier 0 — admins always pick first:
#     Silvio, Paulie
#
#   Tier 1 — deposit met on/before Jun 15:
#     Feech (Jan 5), Sal (Feb 1, overpay then return that stays above the
#     deposit), Bobby (crossing at 2nd payment, Feb 5), Christopher (1st
#     payment $500 is $10 short of the $510 deposit — crossing at 2nd
#     payment, Feb 10), Carlo (Jun 14), Johnny (Jun 15 — deadline-day
#     boundary), Ralph (Jan 10), Hesh (Jan 8)
#
#   Tier 2 — deposit met after Jun 15:
#     Eugene (Jun 20), Jimmy (Jun 25), Richie (Jun 28 — $200 of $360 cost
#     clears the $180 deposit), Artie (Jul 1)
#
#   Tier 3 — deposit not met:
#     Vito ($0 paid), Junior ($400 of $510 deposit), Phil ($0 paid)
#
# Expected /bed_assignments priority order (tier, nights desc, met_at asc):
#   1. Sil (ADMIN)  2. Walnuts (ADMIN)
#   3. Feech  4. Big Pussy  5. Bacala  6. Chrissy  7. Carlo
#   8. Johnny Sack  9. Ralphie  10. Hesh
#   11. Eugene  12. Jimmy  13. Richie  14. Artie
#   15. Vito  16. Junior  17. Phil
# ---------------------------------------------------------------------------

@trip_5.update!(deposit_due_date: Date.parse('2026-06-15'))

def backdate_payments(golfer_trip, *times)
  golfer_trip.payments.order(:id).zip(times).each do |payment, time|
    next unless time
    payment.update_columns(created_at: time, updated_at: time)
  end
end

backdate_payments(@feech_trip,       Time.utc(2026, 1, 5, 12))
backdate_payments(@christopher_trip, Time.utc(2026, 1, 20, 12), Time.utc(2026, 2, 10, 12))
backdate_payments(@eugene_trip,      Time.utc(2026, 6, 20, 12))
backdate_payments(@bobby_trip,       Time.utc(2026, 1, 25, 12), Time.utc(2026, 2, 5, 12), Time.utc(2026, 3, 1, 12))
backdate_payments(@sal_trip,         Time.utc(2026, 2, 1, 12), Time.utc(2026, 2, 20, 12))
backdate_payments(@junior_trip,      Time.utc(2026, 1, 15, 12), Time.utc(2026, 3, 5, 12))
backdate_payments(@ralph_trip,       Time.utc(2026, 1, 10, 12))
backdate_payments(@richie_trip,      Time.utc(2026, 6, 28, 12))
backdate_payments(@johnny_trip,      Time.utc(2026, 6, 15, 12))
backdate_payments(@hesh_trip,        Time.utc(2026, 1, 8, 12))
backdate_payments(@artie_trip,       Time.utc(2026, 7, 1, 12))
backdate_payments(@jimmy_trip,       Time.utc(2026, 6, 25, 12))
backdate_payments(@carlo_trip,       Time.utc(2026, 6, 14, 12))

# Backdate admin registrations for deterministic ordering between the two
# (admins are Tier 0 regardless — they always pick first).
GolferTrip.where(trip: @trip_5, golfer: @silvio).update_all(created_at: Time.utc(2026, 6, 15, 9, 0))
GolferTrip.where(trip: @trip_5, golfer: @paulie).update_all(created_at: Time.utc(2026, 6, 15, 9, 5))

# --- Houses: main + overflow, 13 beds / 19 sleeping spots for 17 golfers ---
# Beds are left unassigned so the assignment flow can be tested from scratch.

@main_house = @trip_5.houses.create!(
  name: 'Main House',
  address: '3000 Sandfiddler Rd, Virginia Beach, VA',
  url: 'https://www.vrbo.com/1234567'
)

@master     = @main_house.bedrooms.create!(name: 'Master Suite')
@ocean_view = @main_house.bedrooms.create!(name: 'Ocean View')
@guest_1    = @main_house.bedrooms.create!(name: 'Guest Room 1')
@guest_2    = @main_house.bedrooms.create!(name: 'Guest Room 2')
@bunk_room  = @main_house.bedrooms.create!(name: 'Bunk Room')
@den        = @main_house.bedrooms.create!(name: 'Den')

@master.beds.create!(description: 'King', capacity: 2, rank: 1)
@ocean_view.beds.create!(description: 'Queen', capacity: 2, rank: 2)
@guest_1.beds.create!(description: 'Queen', capacity: 2, rank: 3)
@guest_2.beds.create!(description: 'Full', capacity: 1, rank: 4)
@bunk_room.beds.create!(description: 'Bunk (bottom)', capacity: 1, rank: 5)
@bunk_room.beds.create!(description: 'Bunk (top)', capacity: 1, rank: 6)
@bunk_room.beds.create!(description: 'Twin', capacity: 1, rank: 7)
@den.beds.create!(description: 'Pullout couch', capacity: 2, rank: 8)
@den.beds.create!(description: 'Air mattress', capacity: 1, rank: 12)

@overflow_house = @trip_5.houses.create!(
  name: 'Overflow House',
  address: '3010 Sandfiddler Rd, Virginia Beach, VA',
  url: 'https://www.vrbo.com/7654321'
)

@upstairs    = @overflow_house.bedrooms.create!(name: 'Upstairs Bedroom')
@living_room = @overflow_house.bedrooms.create!(name: 'Living Room')

@upstairs.beds.create!(description: 'Queen', capacity: 2, rank: 9)
@upstairs.beds.create!(description: 'Full', capacity: 1, rank: 10)
@living_room.beds.create!(description: 'Futon', capacity: 2, rank: 11)
@living_room.beds.create!(description: 'Air mattress', capacity: 1, rank: 13)

# ---------------------------------------------------------------------------
# Furio Giunta — default-role golfer with NO trip registration.
# Use him to test the registration flow end-to-end (deposit policy box,
# acknowledgment checkbox, signup email) without creating a golfer first.
# Login: furio@giunta.it / badabing21
# ---------------------------------------------------------------------------

@furio = Golfer.create!(
  first_name: 'Furio', last_name: 'Giunta', nickname: 'Furio',
  email: 'furio@giunta.it',
  password: 'badabing21', password_confirmation: 'badabing21',
  t_shirt_size: :l
)
