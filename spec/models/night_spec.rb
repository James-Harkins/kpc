require 'rails_helper'

RSpec.describe Night, type: :model do
  describe 'relationships' do
    it { should belong_to(:trip) }
    it { should have_many(:golfer_nights) }
    it { should have_many(:golfers).through(:golfer_nights) }
  end
end
