require 'rails_helper'

RSpec.describe BedAlertOptOut do
  it { should belong_to(:golfer) }
  it { should belong_to(:trip) }

  it 'allows one opt-out per golfer per trip' do
    existing = create(:bed_alert_opt_out)
    dup = BedAlertOptOut.new(golfer: existing.golfer, trip: existing.trip)
    expect(dup).not_to be_valid
  end

  describe '.parties_for' do
    let(:golfer) { create(:golfer) }
    let(:trip)   { create(:trip) }

    it 'round-trips a token to the golfer and trip' do
      token = described_class.token_for(golfer, trip)
      expect(described_class.parties_for(token)).to eq([golfer, trip])
    end

    it 'rejects a tampered token' do
      token = described_class.token_for(golfer, trip)
      expect(described_class.parties_for(token + 'x')).to be_nil
    end

    it 'rejects a missing token' do
      expect(described_class.parties_for(nil)).to be_nil
    end

    it 'rejects a token for a golfer that no longer exists' do
      token = described_class.token_for(golfer, trip)
      golfer.destroy
      expect(described_class.parties_for(token)).to be_nil
    end
  end
end
