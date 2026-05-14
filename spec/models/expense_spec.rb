require 'rails_helper'

RSpec.describe Expense, type: :model do
  let(:trip) do
    Trip.create!(year: 2023, number: 'XXIII', location: 'Dewey Beach',
                 start_date: Date.new(2023, 4, 16))
  end
  let(:golfer) do
    Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'T',
                   email: 't@badabing.com', password: 'test1234',
                   password_confirmation: 'test1234', t_shirt_size: :m)
  end

  describe 'relationships' do
    it { should belong_to(:trip) }
    it { should belong_to(:golfer) }
  end

  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:description) }

    it 'requires amount to be an integer' do
      expense = Expense.new(trip: trip, golfer: golfer, amount: 1.5, description: 'Food')
      expect(expense).not_to be_valid
    end

    it 'requires amount to be non-zero' do
      expense = Expense.new(trip: trip, golfer: golfer, amount: 0, description: 'Food')
      expect(expense).not_to be_valid
    end

    it 'accepts a valid non-zero integer amount' do
      expense = Expense.new(trip: trip, golfer: golfer, amount: 100, description: 'House rental')
      expect(expense).to be_valid
    end
  end

  describe 'callbacks' do
    describe '#set_default_date' do
      it 'sets date to today when not provided' do
        expense = Expense.create!(trip: trip, golfer: golfer, amount: 100, description: 'Food')
        expect(expense.date).to eq(Date.today)
      end

      it 'preserves a provided date' do
        specific_date = Date.new(2023, 4, 16)
        expense = Expense.create!(trip: trip, golfer: golfer, amount: 100,
                                   description: 'Food', date: specific_date)
        expect(expense.date).to eq(specific_date)
      end
    end
  end
end
