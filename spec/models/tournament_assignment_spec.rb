require 'rails_helper'

RSpec.describe TournamentAssignment, type: :model do
  def make_golfer(n)
    Golfer.create!(
      first_name: "Player#{n}", last_name: "Test#{n}", nickname: "P#{n}",
      email: "p#{n}@test.com", password: "password123", password_confirmation: "password123",
      t_shirt_size: :m
    )
  end

  def make_trip(year, number, start_date)
    Trip.create!(year: year, number: number, location: "Test", start_date: start_date)
  end

  describe 'relationships' do
    it { should belong_to(:trip) }
    it { should belong_to(:golfer) }
    it { should belong_to(:round) }
  end

  describe 'validations' do
    it 'requires team to be A or B' do
      trip   = make_trip(2025, 'XXV', Date.new(2025, 4, 20))
      golfer = make_golfer(1)
      round  = trip.rounds.create!(date: Date.new(2025, 4, 21), cost: 0, is_tournament_round: true)

      assignment = TournamentAssignment.new(trip: trip, golfer: golfer, round: round,
                                            team: "C", matchup_group: 1, match_type: "2v2")
      expect(assignment).not_to be_valid
      expect(assignment.errors[:team]).to be_present
    end

    it 'requires matchup_group' do
      trip   = make_trip(2025, 'XXV', Date.new(2025, 4, 20))
      golfer = make_golfer(2)
      round  = trip.rounds.create!(date: Date.new(2025, 4, 21), cost: 0, is_tournament_round: true)

      assignment = TournamentAssignment.new(trip: trip, golfer: golfer, round: round,
                                            team: "A", matchup_group: nil, match_type: "2v2")
      expect(assignment).not_to be_valid
      expect(assignment.errors[:matchup_group]).to be_present
    end

    it 'enforces uniqueness of golfer per (trip, round)' do
      trip   = make_trip(2025, 'XXV', Date.new(2025, 4, 20))
      golfer = make_golfer(3)
      round  = trip.rounds.create!(date: Date.new(2025, 4, 21), cost: 0, is_tournament_round: true)

      TournamentAssignment.create!(trip: trip, golfer: golfer, round: round,
                                   team: "A", matchup_group: 1, match_type: "2v2")
      dup = TournamentAssignment.new(trip: trip, golfer: golfer, round: round,
                                     team: "B", matchup_group: 1, match_type: "2v2")
      expect(dup).not_to be_valid
      expect(dup.errors[:golfer_id]).to be_present
    end
  end

  describe '.build_groups' do
    it 'N mod 4 == 0: all groups of 4' do
      groups = TournamentAssignment.build_groups([*1..16])
      expect(groups.length).to eq(4)
      expect(groups.all? { |g| g.size == 4 }).to be true
    end

    it 'N mod 4 == 2: groups of 4 plus one pair' do
      groups = TournamentAssignment.build_groups([*1..18])
      sizes = groups.map(&:size).sort
      expect(sizes).to eq([2, 4, 4, 4, 4])
    end

    it 'N mod 4 == 3: groups of 4 plus one triple' do
      groups = TournamentAssignment.build_groups([*1..19])
      sizes = groups.map(&:size).sort
      expect(sizes).to eq([3, 4, 4, 4, 4])
    end

    it 'N mod 4 == 1: groups of 4 plus one triple and one pair' do
      groups = TournamentAssignment.build_groups([*1..17])
      sizes = groups.map(&:size).sort
      expect(sizes).to eq([2, 3, 4, 4, 4])
    end
  end

  describe '.generate_for_trip' do
    before do
      @trip = make_trip(2025, 'XXV', Date.new(2025, 4, 20))
      @t_round1 = @trip.rounds.create!(date: Date.new(2025, 4, 24), cost: 0, is_tournament_round: true)
      @t_round2 = @trip.rounds.create!(date: Date.new(2025, 4, 25), cost: 0, is_tournament_round: true)
      @nr_round  = @trip.rounds.create!(date: Date.new(2025, 4, 21), cost: 0, is_tournament_round: false)

      @golfers = (1..8).map { |n| make_golfer(n + 10) }
      @golfers.each_with_index do |g, i|
        # Register in tournament rounds
        GolferRound.create!(golfer: g, round: @t_round1)
        GolferRound.create!(golfer: g, round: @t_round2)
        # Give each golfer a score on the non-tournament round
        GolferRound.create!(golfer: g, round: @nr_round, score: 80 + i)
      end
    end

    it 'creates assignment records for every tournament round' do
      TournamentAssignment.generate_for_trip(@trip)
      [@t_round1, @t_round2].each do |round|
        count = TournamentAssignment.where(trip_id: @trip.id, round_id: round.id).count
        expect(count).to eq(8)
      end
    end

    it 'assigns all golfers to either team A or B' do
      TournamentAssignment.generate_for_trip(@trip)
      assignments = TournamentAssignment.where(trip_id: @trip.id, round_id: @t_round1.id)
      expect(assignments.map(&:team).uniq.sort).to eq(["A", "B"])
      expect(assignments.select { |a| a.team == "A" }.count).to eq(4)
      expect(assignments.select { |a| a.team == "B" }.count).to eq(4)
    end

    it 'does not create assignments for non-tournament rounds' do
      TournamentAssignment.generate_for_trip(@trip)
      count = TournamentAssignment.where(trip_id: @trip.id, round_id: @nr_round.id).count
      expect(count).to eq(0)
    end

    it 'returns early without error when no tournament rounds exist' do
      trip = make_trip(2025, 'XXVI', Date.new(2025, 5, 1))
      trip.rounds.create!(date: Date.new(2025, 5, 2), cost: 0)
      expect { TournamentAssignment.generate_for_trip(trip) }.not_to raise_error
    end
  end

  describe '.generate_for_round' do
    before do
      @trip = make_trip(2025, 'XXVII', Date.new(2025, 4, 20))
      @t_round1 = @trip.rounds.create!(date: Date.new(2025, 4, 24), cost: 0, is_tournament_round: true)
      @t_round2 = @trip.rounds.create!(date: Date.new(2025, 4, 25), cost: 0, is_tournament_round: true)
      @nr_round  = @trip.rounds.create!(date: Date.new(2025, 4, 21), cost: 0, is_tournament_round: false)

      @golfers = (1..8).map { |n| make_golfer(n + 20) }
      @golfers.each_with_index do |g, i|
        GolferRound.create!(golfer: g, round: @t_round1)
        GolferRound.create!(golfer: g, round: @t_round2)
        GolferRound.create!(golfer: g, round: @nr_round, score: 85 + i)
      end

      TournamentAssignment.generate_for_trip(@trip)
    end

    it 'replaces pairings only for the specified round' do
      original_r2 = TournamentAssignment.where(trip_id: @trip.id, round_id: @t_round2.id)
                                        .pluck(:golfer_id, :team, :matchup_group).sort

      TournamentAssignment.generate_for_round(@t_round1, @trip)

      r2_after = TournamentAssignment.where(trip_id: @trip.id, round_id: @t_round2.id)
                                     .pluck(:golfer_id, :team, :matchup_group).sort
      expect(r2_after).to eq(original_r2)
    end
  end

  describe '.average_ranking_score' do
    before do
      @trip = make_trip(2025, 'XXVIII', Date.new(2025, 4, 20))
      @prev_trip = make_trip(2024, 'XXIV', Date.new(2024, 4, 21))
      @golfer = make_golfer(50)
    end

    it 'returns average of current-trip non-tournament scores' do
      r1 = @trip.rounds.create!(date: Date.new(2025, 4, 21), cost: 0)
      r2 = @trip.rounds.create!(date: Date.new(2025, 4, 22), cost: 0)
      GolferRound.create!(golfer: @golfer, round: r1, score: 90)
      GolferRound.create!(golfer: @golfer, round: r2, score: 80)

      avg = TournamentAssignment.average_ranking_score(@golfer.id, @trip)
      expect(avg).to eq(85.0)
    end

    it 'excludes tournament rounds from the average' do
      r1 = @trip.rounds.create!(date: Date.new(2025, 4, 21), cost: 0, is_tournament_round: false)
      r2 = @trip.rounds.create!(date: Date.new(2025, 4, 22), cost: 0, is_tournament_round: true)
      GolferRound.create!(golfer: @golfer, round: r1, score: 80)
      GolferRound.create!(golfer: @golfer, round: r2, score: 100)

      avg = TournamentAssignment.average_ranking_score(@golfer.id, @trip)
      expect(avg).to eq(80.0)
    end

    it 'falls back to previous trip scores when no current-trip scores exist' do
      pr = @prev_trip.rounds.create!(date: Date.new(2024, 4, 22), cost: 0)
      GolferRound.create!(golfer: @golfer, round: pr, score: 95)

      avg = TournamentAssignment.average_ranking_score(@golfer.id, @trip)
      expect(avg).to eq(95.0)
    end

    it 'returns nil when there is no score history' do
      avg = TournamentAssignment.average_ranking_score(@golfer.id, @trip)
      expect(avg).to be_nil
    end
  end

  describe 'algorithm balance for N=16 (mod 4 == 0)' do
    it 'produces equal team rank sums' do
      ranked = [*1..16]
      groups = TournamentAssignment.build_groups(ranked)

      a_ranks = []
      b_ranks = []
      groups.each do |group|
        group.each_with_index do |rank, pos|
          if TournamentAssignment::TEAM_A_POSITIONS[group.size].include?(pos)
            a_ranks << rank
          else
            b_ranks << rank
          end
        end
      end

      expect(a_ranks.sum).to eq(b_ranks.sum)
    end
  end

  describe '.fix_captain_teams!' do
    def assignments_for(groups)
      result = []
      groups.each_with_index do |group, idx|
        group_num   = idx + 1
        size        = group.size
        a_positions = TournamentAssignment::TEAM_A_POSITIONS[size]
        match_type  = TournamentAssignment::MATCH_TYPE[size]
        group.each_with_index do |golfer_id, pos|
          team = a_positions.include?(pos) ? "A" : "B"
          result << { golfer_id: golfer_id, team: team, matchup_group: group_num, match_type: match_type }
        end
      end
      result
    end

    it 'swaps both captains when ca=B and cb=A (both in same group)' do
      # Positions: 0=A, 1=B, 2=B, 3=A — so rank 2 (pos 1) is B, rank 3 (pos 2) is B
      # Build a group of 4 where captain_a lands at pos 1 (B) and captain_b at pos 0 (A)
      # ranked = [cb_id, ca_id, 3, 4] → pos 0=A(cb), 1=B(ca), 2=B, 3=A
      ca_id = 101; cb_id = 102
      assignments = assignments_for([[cb_id, ca_id, 103, 104]])
      expect(assignments.find { |a| a[:golfer_id] == ca_id }[:team]).to eq("B")
      expect(assignments.find { |a| a[:golfer_id] == cb_id }[:team]).to eq("A")

      TournamentAssignment.fix_captain_teams!(assignments, ca_id, cb_id)

      expect(assignments.find { |a| a[:golfer_id] == ca_id }[:team]).to eq("A")
      expect(assignments.find { |a| a[:golfer_id] == cb_id }[:team]).to eq("B")
    end

    it 'moves cb to B when both captains land on A' do
      # ranked = [ca_id, 103, 104, cb_id] → pos 0=A(ca), 3=A(cb) — both on A
      ca_id = 201; cb_id = 202
      assignments = assignments_for([[ca_id, 203, 204, cb_id]])
      expect(assignments.find { |a| a[:golfer_id] == ca_id }[:team]).to eq("A")
      expect(assignments.find { |a| a[:golfer_id] == cb_id }[:team]).to eq("A")

      TournamentAssignment.fix_captain_teams!(assignments, ca_id, cb_id)

      expect(assignments.find { |a| a[:golfer_id] == ca_id }[:team]).to eq("A")
      expect(assignments.find { |a| a[:golfer_id] == cb_id }[:team]).to eq("B")
    end

    it 'moves ca to A when both captains land on B' do
      # ranked = [103, ca_id, cb_id, 104] → pos 1=B(ca), 2=B(cb) — both on B
      ca_id = 301; cb_id = 302
      assignments = assignments_for([[303, ca_id, cb_id, 304]])
      expect(assignments.find { |a| a[:golfer_id] == ca_id }[:team]).to eq("B")
      expect(assignments.find { |a| a[:golfer_id] == cb_id }[:team]).to eq("B")

      TournamentAssignment.fix_captain_teams!(assignments, ca_id, cb_id)

      expect(assignments.find { |a| a[:golfer_id] == ca_id }[:team]).to eq("A")
      expect(assignments.find { |a| a[:golfer_id] == cb_id }[:team]).to eq("B")
    end

    it 'does nothing when ca=A and cb=B (already correct)' do
      # ranked = [ca_id, 403, 404, cb_id] → pos 0=A(ca) ... wait
      # We need ca on A and cb on B in different positions
      # ranked = [ca_id, cb_id, 403, 404] → pos 0=A(ca), 1=B(cb) — already correct
      ca_id = 401; cb_id = 402
      assignments = assignments_for([[ca_id, cb_id, 403, 404]])
      expect(assignments.find { |a| a[:golfer_id] == ca_id }[:team]).to eq("A")
      expect(assignments.find { |a| a[:golfer_id] == cb_id }[:team]).to eq("B")

      original = assignments.map { |a| a.dup }
      TournamentAssignment.fix_captain_teams!(assignments, ca_id, cb_id)

      expect(assignments).to eq(original)
    end
  end

  describe 'algorithm balance for N=17 (mod 4 == 1)' do
    it 'produces avg rank difference less than 1.0 between teams' do
      ranked = [*1..17]
      groups = TournamentAssignment.build_groups(ranked)

      a_ranks = []
      b_ranks = []
      groups.each do |group|
        group.each_with_index do |rank, pos|
          if TournamentAssignment::TEAM_A_POSITIONS[group.size].include?(pos)
            a_ranks << rank
          else
            b_ranks << rank
          end
        end
      end

      a_avg = a_ranks.sum.to_f / a_ranks.size
      b_avg = b_ranks.sum.to_f / b_ranks.size
      expect((a_avg - b_avg).abs).to be < 1.0
    end
  end
end
