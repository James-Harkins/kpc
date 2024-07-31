require 'rails_helper'

RSpec.describe GolferNight, type: :model do
  describe 'relationships' do
    it { should belong_to(:golfer) }
    it { should belong_to(:night) }
  end
end
