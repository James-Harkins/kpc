require 'rails_helper'

RSpec.describe House, type: :model do
  describe 'relationships' do
    it { should belong_to(:trip) }
    it { should have_many(:bedrooms).dependent(:destroy) }
    it { should have_many(:beds).through(:bedrooms) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'destruction' do
    it 'destroys bedrooms and beds, and unassigns golfers' do
      house = create(:house)
      bedroom = create(:bedroom, house: house)
      bed = create(:bed, bedroom: bedroom)
      golfer_trip = create(:golfer_trip, trip: house.trip, bed: bed)

      house.destroy

      expect(Bedroom.exists?(bedroom.id)).to be false
      expect(Bed.exists?(bed.id)).to be false
      expect(golfer_trip.reload.bed_id).to be_nil
    end
  end
end
