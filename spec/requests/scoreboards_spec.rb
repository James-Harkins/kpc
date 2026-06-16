require 'rails_helper'

RSpec.describe 'Scoreboards', type: :request do
  def make_golfer(first:, last:, nickname:, email:, role: :default)
    Golfer.create!(
      first_name: first, last_name: last, nickname: nickname,
      email: email, password: 'test1234', password_confirmation: 'test1234',
      role: role, t_shirt_size: :m
    )
  end

  let!(:admin) do
    make_golfer(first: 'Tony', last: 'Soprano', nickname: 'Tony',
                email: 'tony@badabing.com', role: :admin)
  end

  let!(:non_admin) do
    make_golfer(first: 'Bobby', last: 'Bacalieri', nickname: 'Bobby',
                email: 'bobby@badabing.com')
  end

  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  describe 'GET /scoreboard' do
    context 'when not logged in' do
      it 'redirects to /login' do
        get '/scoreboard'
        expect(response).to redirect_to('/login')
      end
    end

    context 'when logged in as a non-admin golfer' do
      before { log_in_as(non_admin) }

      it 'redirects to /dashboard' do
        get '/scoreboard'
        expect(response).to redirect_to('/dashboard')
      end
    end

    context 'when logged in as an admin' do
      before { log_in_as(admin) }

      context 'when there is no current trip' do
        around do |example|
          orig = ENV['CURRENT_TRIP_NUMBER']
          ENV['CURRENT_TRIP_NUMBER'] = 'NONE'
          example.run
          ENV['CURRENT_TRIP_NUMBER'] = orig
        end

        it 'returns a successful response' do
          get '/scoreboard'
          expect(response).to have_http_status(:ok)
        end

        it 'shows a no active trip message' do
          get '/scoreboard'
          expect(response.body).to match(/no active trip/i)
        end
      end

      context 'with a current trip and non-tournament rounds' do
        before do
          @trip = Trip.create!(year: 2025, number: 'XXV', location: 'Test',
                               start_date: Date.new(2025, 4, 20))
          @course = Course.create!(name: 'Pebble Beach', address: '1700 17-Mile Dr')

          # Two non-tournament rounds (the scoreable ones)
          @round1 = @trip.rounds.create!(date: Date.new(2025, 4, 21), cost: 80,
                                         is_tournament_round: false, course: @course)
          @round2 = @trip.rounds.create!(date: Date.new(2025, 4, 22), cost: 85,
                                         is_tournament_round: false)

          # One tournament round (should be excluded from the scoreboard)
          @t_round = @trip.rounds.create!(date: Date.new(2025, 4, 24), cost: 0,
                                          is_tournament_round: true)

          # golfer_a has higher average (worse) → sorts after golfer_b
          @golfer_a = make_golfer(first: 'Chris', last: 'Moltisanti', nickname: 'Chrissy',
                                  email: 'chris@badabing.com')
          # golfer_b has lower average (better) → sorts first
          @golfer_b = make_golfer(first: 'Paulie', last: 'Gualtieri', nickname: 'Paulie',
                                  email: 'paulie@badabing.com')

          GolferRound.create!(golfer: @golfer_a, round: @round1, score: 90)
          GolferRound.create!(golfer: @golfer_a, round: @round2, score: 88)
          GolferRound.create!(golfer: @golfer_b, round: @round1, score: 82)
          GolferRound.create!(golfer: @golfer_b, round: @round2, score: 80)
        end

        around do |example|
          orig = ENV['CURRENT_TRIP_NUMBER']
          ENV['CURRENT_TRIP_NUMBER'] = 'XXV'
          example.run
          ENV['CURRENT_TRIP_NUMBER'] = orig
        end

        it 'returns a successful response' do
          get '/scoreboard'
          expect(response).to have_http_status(:ok)
        end

        it 'includes the trip number in the page heading' do
          get '/scoreboard'
          expect(response.body).to include('XXV')
        end

        it 'includes the word Scoreboard in the page heading' do
          get '/scoreboard'
          expect(response.body).to match(/[Ss]coreboard/)
        end

        it 'shows the course name for rounds that have a course' do
          get '/scoreboard'
          expect(response.body).to include('Pebble Beach')
        end

        it 'displays a column header for each non-tournament round' do
          get '/scoreboard'
          # round1 date: Apr 21; round2 date: Apr 22 — both should appear
          expect(response.body).to include('Apr')
        end

        it 'displays golfer nicknames' do
          get '/scoreboard'
          expect(response.body).to include('Chrissy')
          expect(response.body).to include('Paulie')
        end

        it 'displays round scores for each golfer' do
          get '/scoreboard'
          expect(response.body).to include('90')
          expect(response.body).to include('88')
          expect(response.body).to include('82')
          expect(response.body).to include('80')
        end

        it 'displays average scores formatted to one decimal place' do
          get '/scoreboard'
          # golfer_a: (90 + 88) / 2 = 89.0
          # golfer_b: (82 + 80) / 2 = 81.0
          expect(response.body).to include('89.0')
          expect(response.body).to include('81.0')
        end

        it 'shows a Total column header' do
          get '/scoreboard'
          expect(response.body).to include('Total')
        end

        it 'shows an Avg column header' do
          get '/scoreboard'
          expect(response.body).to include('Avg')
        end

        it 'sorts golfers by average score ascending (lower is better, sorts first)' do
          get '/scoreboard'
          paulie_pos  = response.body.index('Paulie')
          chrissy_pos = response.body.index('Chrissy')
          expect(paulie_pos).to be < chrissy_pos
        end

        it 'includes a meta refresh tag set to 30 seconds' do
          get '/scoreboard'
          expect(response.body).to match(/http-equiv="refresh"/)
          expect(response.body).to match(/content="30"/)
        end

        it 'includes a dashboard navigation link' do
          get '/scoreboard'
          expect(response.body).to match(/[Dd]ashboard/)
        end

        context 'when a golfer has nil scores (registered for round but score not yet entered)' do
          before do
            @golfer_c = make_golfer(first: 'Junior', last: 'Soprano', nickname: 'Junior',
                                    email: 'junior@badabing.com')
            GolferRound.create!(golfer: @golfer_c, round: @round1, score: nil)
          end

          it 'shows a dash for the missing score' do
            get '/scoreboard'
            expect(response.body).to include('—')
          end

          it 'sorts golfer with no scores entered after golfers with scores' do
            get '/scoreboard'
            junior_pos = response.body.index('Junior')
            paulie_pos = response.body.index('Paulie')
            expect(junior_pos).to be > paulie_pos
          end

          it 'shows a blank average for golfer with no scores entered' do
            get '/scoreboard'
            # Junior appears on the page but without a numeric average
            expect(response.body).to include('Junior')
            expect(response.body).not_to match(/Junior.*\d+\.\d/)
          end
        end

        context 'when a golfer has only a GolferTrip but no GolferRound on non-tournament rounds' do
          before do
            @trip_only_golfer = make_golfer(first: 'Silvio', last: 'Dante', nickname: 'Sil',
                                            email: 'sil@badabing.com')
            @trip.golfer_trips.create!(golfer: @trip_only_golfer, cost: 0, balance: 0,
                                       is_paid: false)
          end

          it 'does not include that golfer on the scoreboard' do
            get '/scoreboard'
            expect(response.body).not_to include('Sil')
          end
        end

        context 'when a golfer is registered only for the tournament round (not non-tournament rounds)' do
          before do
            @tournament_only_golfer = make_golfer(first: 'Meadow', last: 'Soprano',
                                                  nickname: 'Meadow',
                                                  email: 'meadow@badabing.com')
            GolferRound.create!(golfer: @tournament_only_golfer, round: @t_round)
          end

          it 'does not include that golfer on the scoreboard' do
            get '/scoreboard'
            expect(response.body).not_to include('Meadow')
          end
        end

        context 'when two golfers have the same average score' do
          before do
            @golfer_d = make_golfer(first: 'Albert', last: 'Barese', nickname: 'Al',
                                    email: 'al@badabing.com')
            @golfer_e = make_golfer(first: 'Armand', last: 'Zellman', nickname: 'Arnie',
                                    email: 'arnie@badabing.com')
            # Both score 85 avg; Barese sorts before Zellman alphabetically by last name
            GolferRound.create!(golfer: @golfer_d, round: @round1, score: 85)
            GolferRound.create!(golfer: @golfer_e, round: @round1, score: 85)
          end

          it 'sorts tied golfers by last name ascending as a tiebreaker' do
            get '/scoreboard'
            al_pos    = response.body.index('Al')
            arnie_pos = response.body.index('Arnie')
            expect(al_pos).to be < arnie_pos
          end
        end
      end
    end
  end
end
