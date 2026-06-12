require 'rails_helper'

RSpec.describe TournamentMatchupResult, type: :model do
  def make_trip(year, number, start_date)
    Trip.create!(year: year, number: number, location: "Test", start_date: start_date)
  end

  describe 'relationships' do
    it { should belong_to(:round) }
  end

  describe 'validations' do
    let(:trip)  { make_trip(2025, 'XXV', Date.new(2025, 4, 20)) }
    let(:round) { trip.rounds.create!(date: Date.new(2025, 4, 24), cost: 0, is_tournament_round: true) }

    it 'requires matchup_group' do
      result = TournamentMatchupResult.new(round: round, matchup_group: nil, result: "A")
      expect(result).not_to be_valid
      expect(result.errors[:matchup_group]).to be_present
    end

    it 'requires result to be A, B, or tie' do
      result = TournamentMatchupResult.new(round: round, matchup_group: 1, result: "C")
      expect(result).not_to be_valid
      expect(result.errors[:result]).to be_present
    end

    it 'accepts A, B, and tie as valid results' do
      %w[A B tie].each do |r|
        result = TournamentMatchupResult.new(round: round, matchup_group: 1, result: r)
        expect(result).to be_valid
      end
    end

    it 'enforces uniqueness of matchup_group per round' do
      TournamentMatchupResult.create!(round: round, matchup_group: 1, result: "A")
      dup = TournamentMatchupResult.new(round: round, matchup_group: 1, result: "B")
      expect(dup).not_to be_valid
      expect(dup.errors[:matchup_group]).to be_present
    end
  end

  describe '.team_points' do
    before do
      @trip   = make_trip(2025, 'XXVI', Date.new(2025, 4, 20))
      @round1 = @trip.rounds.create!(date: Date.new(2025, 4, 24), cost: 0, is_tournament_round: true)
      @round2 = @trip.rounds.create!(date: Date.new(2025, 4, 25), cost: 0, is_tournament_round: true)
    end

    it 'counts A wins as 1 point for A' do
      TournamentMatchupResult.create!(round: @round1, matchup_group: 1, result: "A")
      pts = TournamentMatchupResult.team_points(@trip)
      expect(pts["A"]).to eq(1)
      expect(pts["B"]).to eq(0)
    end

    it 'counts B wins as 1 point for B' do
      TournamentMatchupResult.create!(round: @round1, matchup_group: 1, result: "B")
      pts = TournamentMatchupResult.team_points(@trip)
      expect(pts["A"]).to eq(0)
      expect(pts["B"]).to eq(1)
    end

    it 'counts ties as 0.5 points to each team' do
      TournamentMatchupResult.create!(round: @round1, matchup_group: 1, result: "tie")
      pts = TournamentMatchupResult.team_points(@trip)
      expect(pts["A"]).to eq(0.5)
      expect(pts["B"]).to eq(0.5)
    end

    it 'aggregates correctly across multiple rounds and groups' do
      # Round 1: group 1 = A wins, group 2 = tie
      TournamentMatchupResult.create!(round: @round1, matchup_group: 1, result: "A")
      TournamentMatchupResult.create!(round: @round1, matchup_group: 2, result: "tie")
      # Round 2: group 1 = B wins, group 2 = A wins
      TournamentMatchupResult.create!(round: @round2, matchup_group: 1, result: "B")
      TournamentMatchupResult.create!(round: @round2, matchup_group: 2, result: "A")

      pts = TournamentMatchupResult.team_points(@trip)
      # A: 1 + 0.5 + 0 + 1 = 2.5
      # B: 0 + 0.5 + 1 + 0 = 1.5
      expect(pts["A"]).to eq(2.5)
      expect(pts["B"]).to eq(1.5)
    end
  end
end
