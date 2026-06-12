require 'rails_helper'

RSpec.describe Round, type: :model do
  describe 'relationships' do
    it { should belong_to(:trip) }
    it { should belong_to(:course).optional }
    it { should have_many(:golfer_rounds) }
    it { should have_many(:golfers).through(:golfer_rounds) }
    it { should have_many(:tournament_assignments) }
    it { should have_many(:tournament_matchup_results) }
  end

  describe 'scopes' do
    before do
      @trip = Trip.create!(year: 2025, number: 'XXV', location: 'Test',
                           start_date: Date.new(2025, 4, 20))
      @t_round  = @trip.rounds.create!(date: Date.new(2025, 4, 24), cost: 0, is_tournament_round: true)
      @nt_round = @trip.rounds.create!(date: Date.new(2025, 4, 21), cost: 0, is_tournament_round: false)
    end

    describe '.tournament' do
      it 'returns only tournament rounds' do
        expect(Round.tournament).to include(@t_round)
        expect(Round.tournament).not_to include(@nt_round)
      end
    end

    describe '.non_tournament' do
      it 'returns only non-tournament rounds' do
        expect(Round.non_tournament).to include(@nt_round)
        expect(Round.non_tournament).not_to include(@t_round)
      end
    end
  end
end
