require 'rails_helper'

RSpec.describe GolferRound, type: :model do
  describe 'relationships' do
    it { should belong_to(:golfer) }
    it { should belong_to(:round) }
  end
end
