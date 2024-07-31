require 'rails_helper'

RSpec.describe GolferTrip, type: :model do
  describe 'relationships' do
    it { should belong_to(:golfer) }
    it { should belong_to(:trip) }
  end
end
