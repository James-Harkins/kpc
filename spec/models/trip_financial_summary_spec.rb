require 'rails_helper'

RSpec.describe TripFinancialSummary, type: :model do
  describe 'relationships' do
    it { should belong_to(:trip) }
  end
end
