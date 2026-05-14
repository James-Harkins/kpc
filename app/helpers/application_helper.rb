module ApplicationHelper
  ROMAN_NUMERALS = [
    [1000, 'M'], [900, 'CM'], [500, 'D'], [400, 'CD'],
    [100, 'C'],  [90,  'XC'], [50,  'L'], [40,  'XL'],
    [10,  'X'],  [9,   'IX'], [5,   'V'], [4,   'IV'],
    [1,   'I']
  ].freeze

  def roman_to_int(roman)
    values = { 'I' => 1, 'V' => 5, 'X' => 10, 'L' => 50,
               'C' => 100, 'D' => 500, 'M' => 1000 }
    result, prev = 0, 0
    roman.upcase.chars.reverse.each do |c|
      val = values[c] || 0
      result += val >= prev ? val : -val
      prev = val
    end
    result
  end

  def int_to_roman(num)
    result = ''
    ROMAN_NUMERALS.each do |value, numeral|
      while num >= value
        result += numeral
        num -= value
      end
    end
    result
  end

  def next_trip_number(roman)
    int_to_roman(roman_to_int(roman) + 1)
  end
end
