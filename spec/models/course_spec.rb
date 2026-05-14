require 'rails_helper'

RSpec.describe Course, type: :model do
  describe 'relationships' do
    it { should have_many(:rounds) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
