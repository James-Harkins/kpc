FactoryBot.define do
  factory :golfer do
    first_name { "Tony" }
    last_name { "Soprano" }
    sequence(:nickname) { |n| "golfer#{n}" }
    sequence(:email) { |n| "golfer#{n}@badabing.com" }
    password { "test1234" }
    password_confirmation { "test1234" }
    role { :default }

    trait :admin do
      role { :admin }
    end
  end

  factory :trip do
    sequence(:year) { |n| 2020 + n }
    sequence(:number) { |n| "TEST#{n}" }
    location { "Dewey Beach" }
    start_date { Date.new(2026, 9, 16) }
    registration_open { true }

    trait :registration_closed do
      registration_open { false }
    end

    trait :with_deposit_deadline do
      deposit_due_date { Date.new(2026, 6, 1) }
    end
  end

  factory :night do
    trip
    sequence(:date) { |n| Date.new(2026, 9, 16) + n.days }
    cost { 65 }
  end

  factory :golfer_night do
    golfer
    night
  end

  factory :golfer_trip do
    golfer
    trip
    cost { 400 }
    balance { 400 }
    is_paid { false }
    is_full_trip { false }
  end

  factory :payment do
    golfer_trip
    amount { 100 }
  end

  factory :house do
    trip
    sequence(:name) { |n| "House #{n}" }
    address { "123 Beach Ave" }
    url { "https://www.vrbo.com/listing" }
  end

  factory :bedroom do
    house
    sequence(:name) { |n| "Bedroom #{n}" }
  end

  factory :bed do
    bedroom
    description { "Queen" }
    capacity { 1 }
    sequence(:rank) { |n| n }
  end

  factory :bed_alert_opt_out do
    golfer
    trip
  end
end
