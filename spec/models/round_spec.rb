require 'rails_helper'

RSpec.describe Round, type: :model do
  describe 'relationships' do
    it { should belong_to(:trip) }
    it { should belong_to(:course).optional }
    it { should have_many(:golfer_rounds) }
    it { should have_many(:golfers).through(:golfer_rounds) }
  end
end
