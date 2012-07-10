FactoryGirl.define do

  factory :asset_tag do
    sequence(:uid) { |n| "867-5309-#{n}" }
    component
  end

  factory :brand do
    name "Sandwich R Us"
  end

  factory :budget do
    number "11-2222"
    name "Slush Fund"
    date_start { Date.today - 30.days }
    date_end { Date.today - 30.days + 2.years }
  end

  factory :business_hour do
    location

    # Monday 11:00am
    open_day "monday"
    open_hour 11
    open_minute 0

    # Monday 3:00pm
    close_day "monday"
    close_hour 15
    close_minute 0
  end

  factory :business_hour_exception do
    date_closed { Date.new(2012, 12, 25) }
  end

  factory :component do
    sequence(:serial_number) { |n| "THX1138-#{n}" }
    kit
  end

  factory :kit do
    budget
    checkoutable false
    cost 47
    insured false
    location
    model
    tombstoned false

    trait :tombstoned do
      tombstoned true
    end

    trait :checkoutable do
      checkoutable true
    end

    trait :insured do
      insured true
    end
  end

  factory :location do
    name "Electric Avenue"
  end

  factory :model do
    name "Fluffernutter"
    description "Oh so tasty and crunchy! Takes AA batteries."
    brand
  end

  factory :user do
    sequence(:username) { |u| "user#{n}" }
    email { "#{username}@example.com".downcase }
    password "secret"
  end

end
