@golfer_1 = Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'T', email: 't@badabing.com', password: 'test', password_confirmation: 'test', role: 1)
@golfer_2 = Golfer.create!(first_name: 'Peter', last_name: 'Gaultieri', nickname: 'Paulie', email: 'walnuts@badabing.com', password: 'test', password_confirmation: 'test')
@golfer_3 = Golfer.create!(first_name: 'Christopher', last_name: 'Moltisanti', nickname: 'Chrissie', email: 'chrissie@badabing.com', password: 'test', password_confirmation: 'test')
@golfer_4 = Golfer.create!(first_name: 'Silvio', last_name: 'Dante', nickname: 'Sil', email: 'manager@badabing.com', password: 'test', password_confirmation: 'test')

@trip_1 = Trip.create!(year: 2013, number: 'XIII', location: 'Dewey Beach')
@trip_2 = Trip.create!(year: 2014, number: 'XIV', location: 'Rehoboth Beach')
@trip_3 = Trip.create!(year: 2015, number: 'XV', location: 'VA Beach')
@trip_4 = Trip.create!(year: 2016, number: 'XVI', location: 'VA Beach')

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

@golfer_1_trip_1 = @golfer_1.golfer_trips.create!(trip: @trip_1)
@golfer_1_trip_1_night_1 = @golfer_1.golfer_nights.create!(night: @night_3_trip_1)
@golfer_1_trip_1_golfer_round_1 = @golfer_1.golfer_rounds.create!(round: @trip_1_course_3)
@golfer_1_trip_1_night_2 = @golfer_1.golfer_nights.create!(night: @night_4_trip_1)
@golfer_1_trip_1_golfer_round_2 = @golfer_1.golfer_rounds.create!(round: @trip_1_course_4)
@golfer_1_trip_1_night_3 = @golfer_1.golfer_nights.create!(night: @night_5_trip_1)
@golfer_1_trip_1_golfer_round_3 = @golfer_1.golfer_rounds.create!(round: @trip_1_course_5)
@golfer_1_trip_1_night_4 = @golfer_1.golfer_nights.create!(night: @night_6_trip_1)
@golfer_1_trip_1_golfer_round_4 = @golfer_1.golfer_rounds.create!(round: @trip_1_course_6)
@golfer_1_trip_1_night_5 = @golfer_1.golfer_nights.create!(night: @night_7_trip_1)

@golfer_1_trip_2 = @golfer_1.golfer_trips.create!(trip: @trip_2)
@golfer_1_trip_2_night_1 = @golfer_1.golfer_nights.create!(night: @night_4_trip_2)
@golfer_1_trip_2_golfer_round_1 = @golfer_1.golfer_rounds.create!(round: @trip_2_course_4)
@golfer_1_trip_2_night_2 = @golfer_1.golfer_nights.create!(night: @night_5_trip_2)
@golfer_1_trip_2_golfer_round_2 = @golfer_1.golfer_rounds.create!(round: @trip_2_course_5)
@golfer_1_trip_2_night_3 = @golfer_1.golfer_nights.create!(night: @night_6_trip_2)
@golfer_1_trip_2_golfer_round_3 = @golfer_1.golfer_rounds.create!(round: @trip_2_course_6)
@golfer_1_trip_2_night_4 = @golfer_1.golfer_nights.create!(night: @night_7_trip_2)

@golfer_1_trip_3 = @golfer_1.golfer_trips.create!(trip: @trip_4)
@golfer_1_trip_3_night_1 = @golfer_1.golfer_nights.create!(night: @night_1_trip_4)
@golfer_1_trip_3_golfer_round_1 = @golfer_1.golfer_rounds.create!(round: @trip_4_course_1)
@golfer_1_trip_3_night_2 = @golfer_1.golfer_nights.create!(night: @night_2_trip_4)
@golfer_1_trip_3_golfer_round_2 = @golfer_1.golfer_rounds.create!(round: @trip_4_course_2)
@golfer_1_trip_3_night_3 = @golfer_1.golfer_nights.create!(night: @night_3_trip_4)
@golfer_1_trip_3_golfer_round_3 = @golfer_1.golfer_rounds.create!(round: @trip_4_course_3)
@golfer_1_trip_3_night_4 = @golfer_1.golfer_nights.create!(night: @night_4_trip_4)
@golfer_1_trip_3_golfer_round_4 = @golfer_1.golfer_rounds.create!(round: @trip_4_course_4)
@golfer_1_trip_3_night_5 = @golfer_1.golfer_nights.create!(night: @night_5_trip_4)
@golfer_1_trip_3_golfer_round_5 = @golfer_1.golfer_rounds.create!(round: @trip_4_course_5)
@golfer_1_trip_3_night_6 = @golfer_1.golfer_nights.create!(night: @night_6_trip_4)
@golfer_1_trip_3_golfer_round_6 = @golfer_1.golfer_rounds.create!(round: @trip_4_course_6)
@golfer_1_trip_3_night_7 = @golfer_1.golfer_nights.create!(night: @night_7_trip_4)

@golfer_2_trip_1 = @golfer_2.golfer_trips.create!(trip: @trip_1)
@golfer_2_trip_1_night_1 = @golfer_2.golfer_nights.create!(night: @night_5_trip_1)
@golfer_2_trip_1_golfer_round_1 = @golfer_2.golfer_rounds.create!(round: @trip_1_course_5)
@golfer_2_trip_1_night_2 = @golfer_2.golfer_nights.create!(night: @night_6_trip_1)
@golfer_2_trip_1_golfer_round_2 = @golfer_2.golfer_rounds.create!(round: @trip_1_course_6)
@golfer_2_trip_1_night_3 = @golfer_2.golfer_nights.create!(night: @night_7_trip_1)

@golfer_2_trip_2 = @golfer_2.golfer_trips.create!(trip: @trip_3)
@golfer_2_trip_2_night_1 = @golfer_2.golfer_nights.create!(night: @night_5_trip_3)
@golfer_2_trip_2_golfer_round_1 = @golfer_2.golfer_rounds.create!(round: @trip_3_course_5)
@golfer_2_trip_2_night_2 = @golfer_2.golfer_nights.create!(night: @night_6_trip_3)
@golfer_2_trip_2_golfer_round_2 = @golfer_2.golfer_rounds.create!(round: @trip_3_course_6)
@golfer_2_trip_2_night_3 = @golfer_2.golfer_nights.create!(night: @night_7_trip_3)

@golfer_3_trip_1 = @golfer_2.golfer_trips.create(trip: @trip_1, is_full_trip: true)

@trip_5 = Trip.create!(year: 2025, number: 'XXV', location: 'VA Beach', start_date: Date.parse('2025-05-03'))
@night_1_trip_5 = @trip_5.nights.create!(date: Date.parse('2024-05-04'), cost: 125)
@night_2_trip_5 = @trip_5.nights.create!(date: Date.parse('2024-05-05'), cost: 125)
@night_3_trip_5 = @trip_5.nights.create!(date: Date.parse('2024-05-06'), cost: 125)
@night_4_trip_5 = @trip_5.nights.create!(date: Date.parse('2024-05-07'), cost: 125)
@night_5_trip_5 = @trip_5.nights.create!(date: Date.parse('2024-05-08'), cost: 125)
@night_6_trip_5 = @trip_5.nights.create!(date: Date.parse('2024-05-09'), cost: 125)
@night_7_trip_5 = @trip_5.nights.create!(date: Date.parse('2024-05-10'), cost: 125)

@trip_5_course_1 = @trip_5.rounds.create!(date: Date.parse('2024-05-05'), cost: 0)
@trip_5_course_2 = @trip_5.rounds.create!(date: Date.parse('2024-05-06'), cost: 0)
@trip_5_course_3 = @trip_5.rounds.create!(date: Date.parse('2024-05-07'), cost: 65)
@trip_5_course_4 = @trip_5.rounds.create!(date: Date.parse('2024-05-08'), cost: 65)
@trip_5_course_5 = @trip_5.rounds.create!(date: Date.parse('2024-05-09'), cost: 65)
@trip_5_course_6 = @trip_5.rounds.create!(date: Date.parse('2024-05-10'), cost: 65)