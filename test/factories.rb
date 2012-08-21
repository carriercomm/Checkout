FactoryGirl.define do

  factory :brand do
    sequence(:name) { |n| "Sandwich R Us ##{n}" }
  end

  factory :budget do
    sequence(:number) {|n| "11-2222-#{n}" }
    name "Slush Fund"
    date_start { Date.today - 30.days }
    date_end { Date.today - 30.days + 2.years }
  end

  factory :business_day do
    index 1
    name "Monday"
  end

  factory :business_hour do
    # Monday 11:30am
    open_hour 11
    open_minute 30

    # Monday 3:20pm
    close_hour 15
    close_minute 20

    factory :business_hour_with_location do
      location
    end
  end

  factory :business_hour_exception do
    date_closed { Date.new(2012, 12, 25) }
  end

  factory :category do
    name "Widgets"
    description "Things that do stuff"
  end

  factory :component do
    sequence(:serial_number) { |n| "THX1138-#{n}" }
    sequence(:asset_tag) { |n| "867-5309-#{n}" }
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

    factory :checkoutable_kit, :traits => [:checkoutable]
    factory :checkoutable_kit_with_location, :traits => [:checkoutable] do
      location
    end

    factory :kit_with_location do
      location
    end

  end

  factory :location do
    name "Electric Avenue"
  end

  factory :model do
    sequence(:name) { |n| "Fluffernutter ##{n}" }
    description "Oh so tasty and crunchy! Takes AA batteries."
    training_required false

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

  factory :role do
    name "roley-role"
  end

  factory :user do
    sequence(:username) { |u| "user#{n}" }
    email { "#{username}@example.com".downcase }
    password "password"

    factory :user_with_role do
      role
    end
  end

end
