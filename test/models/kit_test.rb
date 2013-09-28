require "test_helper"

describe Kit do

  let(:non_circulating_kit) do
    FactoryGirl.build(:kit_with_location)
  end

  let(:circulating_kit) do
    monday     = FactoryGirl.build(:business_day)
    wednesday  = FactoryGirl.build(:business_day, index: 3, name: "Wednesday")
    friday     = FactoryGirl.build(:business_day, index: 5, name: "Friday")
    bh         = FactoryGirl.build(:business_hour, business_days: [monday, wednesday, friday])
    location   = FactoryGirl.create(:location, business_hours: [bh] )
    component1 = FactoryGirl.build(:component_with_branded_component_model)
    component2 = FactoryGirl.build(:component_with_branded_component_model)
    component3 = FactoryGirl.build(:component_with_branded_component_model)
    FactoryGirl.create(:circulating_kit, components: [component1, component2, component3], location: location)
  end

  let(:test_user) do
    FactoryGirl.build(:user)
  end

  let(:test_group_supervisor) do
    FactoryGirl.build(:user, username: 'supervisor')
  end

  let(:test_group) do
    group = FactoryGirl.create(:group)

    # vanilla user
    group.users << test_user

    # group supervisor
    group.users << test_group_supervisor
    membership = group.memberships.where(user_id: test_group_supervisor.id).first
    membership.supervisor = true

    # add a kit to this group
    group.kits << circulating_kit

    group
  end

  let(:requested_loan) do
    test_group
    starts_at = circulating_kit.location.next_datetime_open.to_datetime
    loan      = FactoryGirl.build(:loan, kit: circulating_kit, client: test_user, starts_at: starts_at)
    loan.autofill_ends_at!
    loan.approve!

    refute_nil loan.kit.location
    assert loan.kit.location.business_hours.count > 0

    loan.save!

    assert circulating_kit.circulating?, "kit should be circulating"
    assert circulating_kit.valid?,       "kit should be valid"
    assert test_user.valid?,             "user should be valid"
    refute loan.kit.nil?,                "loan should have a kit"
    refute loan.kit.location.nil?,       "kit should have a location"
    refute_nil loan.ends_at,             "ends_at should not be nil"
    refute loan.starts_at.nil?,          "starts_at should not be nil"
    assert loan.requested?,              "loan should be in a pending state"
    assert loan.valid?,                  "loan should be valid\n#{loan.errors.inspect}"

    loan
  end

  let(:checked_out_loan) do
    attendant = FactoryGirl.build(:attendant_user)
    requested_loan.new_check_out_inventory_record(attendant: attendant)
    requested_loan.check_out_inventory_record.inventory_details.each {|id| id.missing = false }
    requested_loan.check_out!
    requested_loan.save!

    assert requested_loan.checked_out?, "loan should be checked_out"
    assert requested_loan.kit.checked_out?

    requested_loan
  end

  it "should properly indicate when it is checked out" do
    k = checked_out_loan.kit
    assert k.checked_out?, "kit should think it's checked out"
  end

  it "should know when it's available" do
    loan = checked_out_loan
    kit = loan.kit
    loan_start = loan.starts_at
    loan_end  = loan.ends_at

    refute kit.available?(loan_start, loan_end), "kit should not be available since it should conflict with itself"
    assert kit.available?(loan_start, loan_end, loan), "kit should be available since it should exclude itself"

    # check for conflicts with upcoming requests
    test_group
    starts_at = kit.location.next_datetime_open(loan.ends_at)
    requested_loan = FactoryGirl.build(:loan, kit: kit, client: test_user, starts_at: starts_at)
    requested_loan.autofill_ends_at!
    requested_loan.approve!
    requested_loan.save!

    refute kit.available?(requested_loan.starts_at, requested_loan.ends_at)
    refute kit.available?(requested_loan.starts_at, requested_loan.ends_at, loan)
    refute kit.available?(requested_loan.starts_at + 1.days, requested_loan.ends_at)
    refute kit.available?(requested_loan.starts_at + 1.days, requested_loan.ends_at, loan)
    refute kit.available?(requested_loan.starts_at, requested_loan.ends_at - 1.days)
    refute kit.available?(requested_loan.starts_at, requested_loan.ends_at - 1.days, loan)

  end

  it "should return only kits with currently missing components" do
    component = FactoryGirl.build(:component_with_branded_component_model)
    kit       = FactoryGirl.build(:kit_with_location)
    kit.components << component
    kit.save
    assert kit.valid?, "kit should be valid: \n#{kit.errors.inspect}"
    assert component.valid?

    attendant = FactoryGirl.build(:attendant_user)

    ir = FactoryGirl.build(:audit_inventory_record)
    ir.attendant = attendant
    ir.kit = kit
    ir.initialize_inventory_details(true)
    ir.save

    assert_includes Kit.with_missing_components, kit, "Kit missing components collection should include the kit"

    ir2 = FactoryGirl.build(:audit_inventory_record)
    ir2.attendant = attendant
    ir2.kit = kit
    ir2.initialize_inventory_details(false)
    ir2.save

    refute_includes Kit.with_missing_components, kit, "Kit.missing components collection should not include the kit"

  end


end
