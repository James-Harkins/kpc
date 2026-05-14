require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'relationships' do
    it { should belong_to(:golfer_trip) }
  end
end
