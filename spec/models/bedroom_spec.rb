require 'rails_helper'

RSpec.describe Bedroom, type: :model do
  describe 'relationships' do
    it { should belong_to(:house) }
    it { should have_many(:beds).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
