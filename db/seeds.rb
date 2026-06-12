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

@trip_5 = Trip.create!(year: 2026, number: 'XXVI', location: 'VA Beach', start_date: Date.parse('2026-04-18'))
@night_1_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-04-18'), cost: 120)
@night_2_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-04-19'), cost: 120)
@night_3_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-04-20'), cost: 120)
@night_4_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-04-21'), cost: 120)
@night_5_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-04-22'), cost: 120)
@night_6_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-04-23'), cost: 120)
@night_7_trip_5 = @trip_5.nights.create!(date: Date.parse('2026-04-24'), cost: 120)

@trip_5_course_1 = @trip_5.rounds.create!(date: Date.parse('2026-04-19'), cost: 0)
@trip_5_course_2 = @trip_5.rounds.create!(date: Date.parse('2026-04-20'), cost: 0)
@trip_5_course_3 = @trip_5.rounds.create!(date: Date.parse('2026-04-21'), cost: 75)
@trip_5_course_4 = @trip_5.rounds.create!(date: Date.parse('2026-04-22'), cost: 75)
@trip_5_course_5 = @trip_5.rounds.create!(date: Date.parse('2026-04-23'), cost: 75, is_tournament_round: true)
@trip_5_course_6 = @trip_5.rounds.create!(date: Date.parse('2026-04-24'), cost: 75, is_tournament_round: true)

# ---------------------------------------------------------------------------
# Sopranos golfers — 15 trip 5 registrations
#
# Trip 5 costs (full trip):
#   7 nights × $120 = $840, 6 rounds = $0+$0+$75+$75+$75+$75 = $300
#   Gross = $1,140 — first night discount ($120) = $1,020 net
#
# Night → round mapping (sequential logic):
#   Stay night Apr N, wake up and play round Apr N+1
#   Night 1 (Apr 18) → Round 1 (Apr 19)
#   Night 2 (Apr 19) → Round 2 (Apr 20)
#   Night 3 (Apr 20) → Round 3 (Apr 21)
#   Night 4 (Apr 21) → Round 4 (Apr 22)
#   Night 5 (Apr 22) → Round 5 (Apr 23)
#   Night 6 (Apr 23) → Round 6 (Apr 24)
#   Night 7 (Apr 24) → depart, no round
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

# 9. Ralph Cifaretto — arrives Thu (night 4, Apr 21), departs Sun (after night 7, Apr 24)
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

# 10. Richard Aprile — arrives Sat (night 1, Apr 18), departs Tue (after night 3, Apr 20)
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

# 11. John Sacrimoni — arrives Sun (night 2, Apr 19), departs Fri (after night 6, Apr 23)
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

# 12. Phil Leotardo — arrives Mon (night 3, Apr 20), departs Thu (after night 5, Apr 22)
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

# 13. Herman Rabkin — just the opening weekend (nights 1-2, Apr 18-19), round 1 only
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

# 14. Arthur Bucco — late arrival, Wed through end (nights 5-7, Apr 22-24), rounds 5-6
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

# 15. Jimmy Altieri — Sun through Tue (nights 2-4, Apr 19-21), rounds 2-3
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
# Rounds 5 (Apr 23) and 6 (Apr 24) are tournament rounds.
# Rounds 1–4 are scoring rounds used to rank players before team generation.
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

# Round 1 (Apr 19) — full-trip golfers, Richie, Hesh
set_score(@feech,       @trip_5_course_1, 74)
set_score(@christopher, @trip_5_course_1, 80)
set_score(@eugene,      @trip_5_course_1, 84)
set_score(@bobby,       @trip_5_course_1, 88)
set_score(@vito,        @trip_5_course_1, 92)
set_score(@sal,         @trip_5_course_1, 96)
set_score(@carlo,       @trip_5_course_1, 99)
set_score(@junior,      @trip_5_course_1, 103)

# Round 2 (Apr 20) — full-trip golfers, Richie, Johnny, Jimmy
set_score(@feech,       @trip_5_course_2, 72)
set_score(@christopher, @trip_5_course_2, 78)
set_score(@eugene,      @trip_5_course_2, 86)
set_score(@bobby,       @trip_5_course_2, 90)
set_score(@vito,        @trip_5_course_2, 94)
set_score(@sal,         @trip_5_course_2, 98)
set_score(@carlo,       @trip_5_course_2, 101)
set_score(@junior,      @trip_5_course_2, 105)
set_score(@johnny,      @trip_5_course_2, 87)

# Round 3 (Apr 21) — full-trip golfers, Phil, Johnny, Jimmy
set_score(@feech,       @trip_5_course_3, 76)
set_score(@christopher, @trip_5_course_3, 82)
set_score(@eugene,      @trip_5_course_3, 83)
set_score(@bobby,       @trip_5_course_3, 87)
set_score(@vito,        @trip_5_course_3, 90)
set_score(@sal,         @trip_5_course_3, 95)
set_score(@carlo,       @trip_5_course_3, 100)
set_score(@junior,      @trip_5_course_3, 102)
set_score(@johnny,      @trip_5_course_3, 88)

# Round 4 (Apr 22) — full-trip golfers, Ralph, Phil, Johnny
set_score(@feech,       @trip_5_course_4, 75)
set_score(@christopher, @trip_5_course_4, 79)
set_score(@eugene,      @trip_5_course_4, 85)
set_score(@bobby,       @trip_5_course_4, 91)
set_score(@vito,        @trip_5_course_4, 93)
set_score(@sal,         @trip_5_course_4, 97)
set_score(@carlo,       @trip_5_course_4, 98)
set_score(@junior,      @trip_5_course_4, 106)
set_score(@ralph,       @trip_5_course_4, 94)
