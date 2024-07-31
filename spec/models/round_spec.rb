require 'rails_helper'

RSpec.describe Round, type: :model do
  it { should belong_to(:trip) }
  it { should have_many(:golfer_rounds)}
  it { should have_many(:golfers).through(:golfer_rounds)}
end
