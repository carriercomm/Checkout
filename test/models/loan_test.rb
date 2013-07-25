require 'test_helper'

describe Loan do

  # let(:app_config) do
  #   FactoryGirl.create(:app_config)
  # end

  let(:kit) do
    monday     = FactoryGirl.build(:business_day)
    wednesday  = FactoryGirl.build(:business_day, index: 3, name: "Wednesday")
    friday     = FactoryGirl.build(:business_day, index: 5, name: "Friday")
    bh         = FactoryGirl.build(:business_hour, business_days: [monday, wednesday, friday])
    location   = FactoryGirl.build(:location, business_hours: [bh] )
    component1 = FactoryGirl.build(:component_with_branded_component_model, asset_tag: "AAA")
    FactoryGirl.build(:kit, components: [component1], location: location)
  end

  let(:user) do
    FactoryGirl.create(:user)
  end


  # editing a loan should force it to be re-approved
  # ends_at should be the next available check in day after the default checkout duration (taking holidays and weekends in to account)

  it "should auto-approve a valid pending loan with nil end date" do
    group = FactoryGirl.create(:group)
    group.users << user
    group.kits << kit

    starts_at       = kit.location.next_time_open
    loan            = FactoryGirl.build(:loan, kit: kit, client: user, starts_at: starts_at)
    kit.circulating = true

    assert kit.circulating?,       "kit should be circulating"
    assert kit.valid?,             "kit should be valid"
    assert user.valid?,            "user should be valid"
    refute loan.kit.nil?,          "loan should have a kit"
    refute loan.kit.location.nil?, "kit should have a location"
    assert loan.ends_at.nil?,      "ends_at should be nil"
    refute loan.starts_at.nil?,    "starts_at should not be nil"
    assert loan.pending?,          "loan should be in a pending state"
    assert loan.valid?,            "loan should be valid"
    loan.auto_approve!
    assert loan.approved?
  end

  it "should auto-approve a valid pending loan with nil end date on save" do
    group = FactoryGirl.create(:group)
    group.users << user
    group.kits << kit

    starts_at       = kit.location.next_time_open
    loan            = FactoryGirl.build(:loan, kit: kit, client: user, starts_at: starts_at)
    kit.circulating = true

    assert kit.circulating?,       "kit should be circulating"
    assert kit.valid?,             "kit should be valid"
    assert user.valid?,            "user should be valid"
    refute loan.kit.nil?,          "loan should have a kit"
    refute loan.kit.location.nil?, "kit should have a location"
    assert loan.ends_at.nil?,      "ends_at should be nil"
    refute loan.starts_at.nil?,    "starts_at should not be nil"
    assert loan.pending?,          "loan should be in a pending state"
    assert loan.valid?,            "loan should be valid"
    loan.save
    assert loan.approved?
  end

  it "should auto-fill a valid end date if everything else is valid" do
    group = FactoryGirl.create(:group)
    group.users << user
    group.kits << kit

    starts_at       = kit.location.next_time_open
    loan            = FactoryGirl.build(:loan, kit: kit, client: user, starts_at: starts_at)
    kit.circulating = true

    assert kit.circulating?,       "kit should be circulating"
    assert kit.valid?,             "kit should be valid"
    assert user.valid?,            "user should be valid"
    refute loan.kit.nil?,          "loan should have a kit"
    refute loan.kit.location.nil?, "kit should have a location"
    assert loan.ends_at.nil?,      "ends_at should be nil: #{loan.ends_at.inspect}"
    refute loan.starts_at.nil?,    "starts_at should not be nil"
    assert loan.pending?,          "loan should be in a pending state"
    assert loan.valid?,            "loan should be valid #{ loan.errors.inspect}"
    assert loan.ends_at,           "loan should have an end date after validation"
  end


  # non-circulating kits should not be loan-able
  it "should not be valid with with a non-circulating kit" do
    group     = FactoryGirl.build(:group, kits: [kit], users: [user])
    starts_at = kit.location.next_time_open
    loan      = FactoryGirl.build(:loan, kit: kit, client: user, starts_at: starts_at)
    loan.autofill_ends_at!

    refute kit.circulating?
    assert kit.valid?
    assert user.valid?
    assert loan.pending?
    refute loan.kit.nil?
    refute loan.kit.location.nil?
    refute loan.ends_at.nil?
    refute loan.starts_at.nil?
    assert loan.open_on_starts_at?,                 "location should be open on the starting day of the loan"
    refute loan.kit.permissions_include?(loan.client), "client should not have permission to check out the non-circulating kit"
    refute loan.client.disabled?,                   "client should not be disabled"
    refute loan.client.suspended?,                  "client should not be suspended"
    refute loan.kit_available?,                     "non-circulating kits should not be available during checkout dates"
    assert loan.location.open_on?(loan.ends_at),    "location should be open on the day the loan ends"
    assert loan.starts_at < loan.ends_at,           "the loan start date should come before the loan end date"
    refute loan.valid?

  end

end
