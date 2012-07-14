FactoryGirl.define do

  factory :brand do
    name "Sandwich R Us"
  end

  factory :budget do
    sequence(:number) {|n| "11-2222-#{n}" }
    name "Slush Fund"
    date_start { Date.today - 30.days }
    date_end { Date.today - 30.days + 2.years }
  end

  factory :business_hour do
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
    sequence(:asset_tag) { |n| "867-5309-#{n}" }

    factory :component_with_model do
      association :model, :factory => :model_with_brand
    end

  end

  factory :kit do
    budget
    checkoutable false
    cost 47
    insured false
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

    factory :kit_with_location do
      location
    end

  end

  factory :location do
    name "Electric Avenue"
  end

  factory :model do
    name "Fluffernutter"
    description "Oh so tasty and crunchy! Takes AA batteries."

    factory :model_with_brand do
      brand
    end

    # factory :model_with_component_and_kit do
    #   kits { |kits| [kits.association(:kit_with_location)]}
    # end

    # factory :model_with_component_and_kit do
    #   after_build do |model|
    #     model.components << FactoryGirl.build(:component_with_kit, :model => model)
    #   end
    # end

  end

  factory :user do
    sequence(:username) { |u| "user#{n}" }
    email { "#{username}@example.com".downcase }
    password "secret"
  end

end
