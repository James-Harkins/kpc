require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#roman_to_int' do
    it 'converts a single Roman numeral to its integer value' do
      expect(helper.roman_to_int('I')).to eq(1)
      expect(helper.roman_to_int('V')).to eq(5)
      expect(helper.roman_to_int('X')).to eq(10)
      expect(helper.roman_to_int('L')).to eq(50)
      expect(helper.roman_to_int('C')).to eq(100)
      expect(helper.roman_to_int('D')).to eq(500)
      expect(helper.roman_to_int('M')).to eq(1000)
    end

    it 'converts additive Roman numerals' do
      expect(helper.roman_to_int('XIII')).to eq(13)
      expect(helper.roman_to_int('XXIII')).to eq(23)
      expect(helper.roman_to_int('VIII')).to eq(8)
    end

    it 'converts subtractive Roman numerals' do
      expect(helper.roman_to_int('IV')).to eq(4)
      expect(helper.roman_to_int('IX')).to eq(9)
      expect(helper.roman_to_int('XL')).to eq(40)
      expect(helper.roman_to_int('XC')).to eq(90)
      expect(helper.roman_to_int('CD')).to eq(400)
      expect(helper.roman_to_int('CM')).to eq(900)
    end

    it 'converts lowercase Roman numerals' do
      expect(helper.roman_to_int('xiii')).to eq(13)
      expect(helper.roman_to_int('xxiii')).to eq(23)
    end
  end

  describe '#int_to_roman' do
    it 'converts single-value integers' do
      expect(helper.int_to_roman(1)).to eq('I')
      expect(helper.int_to_roman(5)).to eq('V')
      expect(helper.int_to_roman(10)).to eq('X')
      expect(helper.int_to_roman(1000)).to eq('M')
    end

    it 'converts integers requiring multiple numerals' do
      expect(helper.int_to_roman(13)).to eq('XIII')
      expect(helper.int_to_roman(23)).to eq('XXIII')
      expect(helper.int_to_roman(8)).to eq('VIII')
    end

    it 'converts integers requiring subtractive notation' do
      expect(helper.int_to_roman(4)).to eq('IV')
      expect(helper.int_to_roman(9)).to eq('IX')
      expect(helper.int_to_roman(40)).to eq('XL')
      expect(helper.int_to_roman(90)).to eq('XC')
      expect(helper.int_to_roman(400)).to eq('CD')
      expect(helper.int_to_roman(900)).to eq('CM')
    end

    it 'is the inverse of roman_to_int' do
      [1, 4, 5, 9, 13, 23, 25, 40, 50, 90, 100, 400, 500, 900, 1000].each do |n|
        expect(helper.roman_to_int(helper.int_to_roman(n))).to eq(n)
      end
    end
  end

  describe '#next_trip_number' do
    it 'returns the next Roman numeral in sequence' do
      expect(helper.next_trip_number('XXII')).to eq('XXIII')
      expect(helper.next_trip_number('XII')).to eq('XIII')
      expect(helper.next_trip_number('I')).to eq('II')
    end
  end
end
