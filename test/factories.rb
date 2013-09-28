FactoryGirl.define do

  sequence(:id) { |n| n }

  factory :audit_inventory_record do
    attendant
  end

  factory :brand do
    after(:build) do |b|
      n      = FactoryGirl.generate :id
      b.name = "Sandwich R Us ##{n}"
    end
  end

  factory :budget do
    sequence(:number) {|n| "11-2222-#{n}" }
    name "Slush Fund"
    starts_at { Date.today - 30.days }
    ends_at { Date.today - 30.days + 2.years }
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
  end

  factory :business_hour_exception do
    closed_at { Date.new(2012, 12, 25) }
  end

  factory :category do
    name "Widgets"
    description "Things that do stuff"
  end

  factory :check_in_inventory_record do
    attendant
  end

  factory :check_out_inventory_record do
    attendant
  end

  factory :component do
    sequence(:serial_number) { |n| "THX1138-#{n}" }
    sequence(:asset_tag) { |n| "867-5309-#{n}" }
    budget
    cost 47

    factory :component_with_branded_component_model do
      association :component_model, :factory => :branded_component_model, :strategy => :build
    end

  end

  factory :component_model do
    description "Oh so tasty and crunchy! Takes AA batteries."
    training_required false

    after(:build) do |cm|
      n      = FactoryGirl.generate :id
      cm.name = "Fluffernutter #{n}"
    end

    factory :branded_component_model do
      association :brand, :strategy => :build
    end
  end

  factory :group do
    after(:build) do |g|
      n      = FactoryGirl.generate :id
      g.name = "Ariste Grouparama #{n}"
    end
  end

  factory :kit do
    workflow_state "non_circulating"

    trait :is_circulating do
      workflow_state "circulating"
    end

    trait :is_deaccessioned do
      workflow_state "deaccessioned"
    end

    trait :has_location do
      location
    end

    factory :circulating_kit, :traits => [:is_circulating]
    factory :circulating_kit_with_location, :traits => [:is_circulating, :has_location]
    factory :kit_with_location, :traits => [:has_location]
  end

  factory :inventory_detail do
    missing false
  end

  factory :loan do
    starts_at Date.today - 1.day
    #ends_at   Date.today + 1.day
  end

  factory :location do
    after(:build) do |l|
      n      = FactoryGirl.generate :id
      l.name = "#{n } Electric Avenue"
    end

    factory :location_with_business_hours do
      after_create do |l|
        l.business_hours << create(:business_hour_with_business_day)
      end
    end

  end

  factory :permission

  factory :role do
    name "roley-role"
  end

  factory :training

  factory :user do
    sequence(:username) { |n| "user#{n}" }
    email { "#{username}@example.com".downcase }
    password "password"

    factory :admin_user do
      after(:build) do |u|
        admin_role = Role.find_by_name("admin")
        raise "missing admin role" unless admin_role
        u.roles << admin_role
      end
    end

    factory :approver_user do
      after(:build) do |u|
        approver_role = Role.find_by_name("approver")
        raise "missing approver role" unless approver_role
        u.roles << approver_role
      end
    end

    factory :attendant_user, aliases: ['attendant'] do
      after(:build) do |u|
        attendant_role = Role.find_by_name("attendant")
        raise "missing attendant role" unless attendant_role
        u.roles << attendant_role
      end
    end

  end

end
