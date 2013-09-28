require 'test_helper'

describe Loan do

  let(:test_kit) do
    monday     = FactoryGirl.build(:business_day)
    wednesday  = FactoryGirl.build(:business_day, index: 3, name: "Wednesday")
    friday     = FactoryGirl.build(:business_day, index: 5, name: "Friday")
    bh         = FactoryGirl.build(:business_hour, business_days: [monday, wednesday, friday])
    location   = FactoryGirl.create(:location, business_hours: [bh] )
    component1 = FactoryGirl.build(:component_with_branded_component_model)
    component2 = FactoryGirl.build(:component_with_branded_component_model)
    component3 = FactoryGirl.build(:component_with_branded_component_model)
    FactoryGirl.build(:kit, components: [component1, component2, component3], location: location)
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
    group.kits << test_kit

    group
  end

  let(:valid_loan) do
    test_group
    starts_at = test_kit.location.next_datetime_open.to_datetime
    loan      = FactoryGirl.build(:loan, kit: test_kit, client: test_user, starts_at: starts_at)
    loan.autofill_ends_at!
    test_kit.circulate!

    assert test_kit.circulating?,  "kit should be circulating"
    assert test_kit.valid?,        "kit should be valid"
    assert test_user.valid?,       "user should be valid"
    refute_nil loan.kit,           "loan should have a kit"
    refute_nil loan.kit.location,  "kit should have a location"
    refute_nil loan.starts_at,     "starts_at should not be nil"
    refute_nil loan.ends_at,       "ends_at should not be nil"
    assert loan.pending?,          "loan should be in a pending state"
    assert loan.valid?,            "loan should be valid\n#{loan.errors.inspect}"
    loan
  end

  # TODO: ends_at should be the next available check in day after the default checkout duration (taking holidays and weekends in to account)

  it "should automatically select a kit based on component_model in the approval transition" do
    test_group
    starts_at = test_kit.location.next_datetime_open.to_datetime
    loan      = FactoryGirl.build(:loan, kit: test_kit, client: test_user, starts_at: starts_at)
    loan.autofill_ends_at!
    test_kit.circulate!

    assert test_kit.circulating?,  "kit should be circulating"
    assert test_kit.valid?,        "kit should be valid"
    assert test_user.valid?,       "user should be valid"
    refute_nil loan.kit,          "loan should have a kit"
    refute_nil loan.kit.location, "kit should have a location"
    refute_nil loan.ends_at,      "ends_at should not be nil"
    refute loan.starts_at.nil?,    "starts_at should not be nil"
    assert loan.pending?,          "loan should be in a pending state"
    assert loan.valid?,            "loan should be valid\n#{loan.errors.inspect}"
  end

  it "should properly initialize CheckInInventoryRecord and CheckOutInventoryRecord with nested attributes" do
    attendant = FactoryGirl.create(:attendant_user)
    valid_loan.approve!
    assert valid_loan.requested?,     "loan should be requested"
    assert attendant.attendant?,     "attendant should have 'attendant' role"
    valid_loan.save

    # check out
    valid_loan.check_out!
    assert valid_loan.halted?,        "should have halted transition to checked_out because components were not inventoried"
    assert_nil valid_loan.check_out_inventory_record, "check_out_inventory_record should be nil"
    valid_loan.new_check_out_inventory_record(attendant: attendant)
    refute_nil valid_loan.check_out_inventory_record, "check_out_inventory_record should not be nil"
    num_inv_dets   = valid_loan.check_out_inventory_record.inventory_details.size
    num_components = valid_loan.kit.components.size
    assert_equal num_inv_dets, num_components, "expected #{num_components.to_s} inventory details, but got #{num_inv_dets.to_s}"
    valid_loan.check_out!
    assert valid_loan.checked_out?

    #check in
    valid_loan.check_in!
    assert valid_loan.halted?,        "should have halted transition to checked_in because components were not inventoried"
    assert_nil valid_loan.check_in_inventory_record, "check_in_inventory_record should be nil"
    valid_loan.new_check_in_inventory_record(attendant: attendant)
    refute_nil valid_loan.check_in_inventory_record, "check_in_inventory_record should not be nil"
    num_inv_dets   = valid_loan.check_in_inventory_record.inventory_details.size
    assert_equal num_inv_dets, num_components, "expected #{num_components.to_s} inventory details, but got #{num_inv_dets.to_s}"
    valid_loan.check_in!
    assert valid_loan.checked_in?
  end

  it "should be renewable - unless it's not" do
    attendant = FactoryGirl.create(:attendant_user)
    valid_loan.approve!
    valid_loan.new_check_out_inventory_record(attendant: attendant)
    valid_loan.check_out_inventory_record.inventory_details.each {|id| id.missing = false}
    valid_loan.check_out!

    inventoried_component_ids = valid_loan.check_out_inventory_record.inventory_details.map(&:component_id)
    #assert false, "ids: [#{inventoried_component_ids.join(",")}], components: [#{ valid_loan.kit.component_ids.sort.join(",") }]"

    assert valid_loan.checked_out?, "loan should be checked out: #{valid_loan.halted_because.to_s}"
    valid_loan.save
    orig_ends_at = valid_loan.ends_at
    renewals     = valid_loan.renewals + 1
    valid_loan.renew!
    new_ends_at  = valid_loan.ends_at
    assert(orig_ends_at < new_ends_at, "renewal date should be greater than the original return date")
    assert(renewals == valid_loan.renewals, "renewal count should be greater after renewing")
  end

  # it "should not transition to requested when non-default duration and/or invalid approval" do
  #   time = valid_loan.starts_at + Settings.default_loan_duration + 10.days
  #   time = Time.local(time.year, time.month, time.day, time.hour, time.min, time.sec)
  #   valid_loan.ends_at = valid_loan.kit.location.next_datetime_open(time)
  #   assert valid_loan.valid?,   "loan should still be valid in the pending state"
  #   valid_loan.approve!
  #   assert valid_loan.halted?,  "transition to requested should have halted since duration is too long"
  #   assert valid_loan.pending?, "loan should be pending since loan exceeds standard checkout time"

  #   valid_loan.approver = FactoryGirl.create(:user)
  #   valid_loan.approve!
  #   assert valid_loan.halted?,  "transition to requested should have halted since approver doesn't have suffient role"
  #   assert valid_loan.pending?, "loan should be pending since user doesn't have approval role"

  #   valid_loan.approver = FactoryGirl.create(:attendant_user)
  #   valid_loan.approve!
  #   assert valid_loan.halted?,  "transition to requested should have halted since approver doesn't have suffient role"
  #   assert valid_loan.pending?, "loan should be pending since attendant doesn't have approval role"

  #   valid_loan.approver = FactoryGirl.create(:approver_user)
  #   valid_loan.approve!
  #   refute valid_loan.halted?,   "should have transitioned to approve"
  #   assert valid_loan.requested?, "loan should be requested since there is an approver"
  #   assert valid_loan.valid?,    "loan should be valid"
  # end

  # it "should approve default duration with approval from someone with 'approver' role" do
  #   valid_loan.approver = FactoryGirl.create(:user)
  #   valid_loan.approve!
  #   assert valid_loan.halted?,  "transition to requested should have halted since approver doesn't have suffient role"
  #   assert valid_loan.pending?, "loan should be pending since user doesn't have approval role"

  #   valid_loan.approver = FactoryGirl.create(:attendant_user)
  #   valid_loan.approve!
  #   assert valid_loan.halted?,  "transition to requested should have halted since approver doesn't have suffient role"
  #   assert valid_loan.pending?, "loan should be pending since attendant doesn't have approval role"

  #   valid_loan.approver = FactoryGirl.create(:approver_user)
  #   valid_loan.approve!
  #   refute valid_loan.halted?,   "should have transitioned to approve"
  #   assert valid_loan.requested?, "loan should be requested since there is an approver"
  #   assert valid_loan.valid?,    "loan should be valid"
  # end

  it "should auto-approve a valid pending loan with nil end date" do
    valid_loan.approve!
    assert valid_loan.requested?, "loan should be requested"
    assert valid_loan.ends_at,   "loan should have an end date after automatic approval"
    assert valid_loan.valid?,    "loan should be valid"
  end

  # it "should update ends_at when starts_at is changed" do
  #   valid_loan.approve!
  #   assert valid_loan.requested?, "loan should be requested"
  #   assert valid_loan.ends_at,   "loan should have an end date after automatic approval"
  #   old_ends_at   = valid_loan.ends_at
  #   time          = valid_loan.starts_at + 1.days
  #   time          = Time.local(time.year, time.month, time.day, time.hour, time.min, time.sec)
  #   new_starts_at = valid_loan.location.next_datetime_open(time)
  #   valid_loan.starts_at = new_starts_at
  #   assert valid_loan.pending?,  "loan should change to pending after altering starts_at"
  #   #assert valid_loan.requested?, "loan should be requested after only changing starts_at"
  #   refute_equal(valid_loan.ends_at, old_ends_at, "loan ends_at should be automatically adjusted when starts_at is changed")
  #   assert valid_loan.valid?,    "loan should be valid"
  # end

  # it "should transition to pending when ends_at is changed and the resulting checkout length is non-default" do
  #   valid_loan.approve!
  #   assert valid_loan.requested?, "loan should be requested"
  #   valid_loan.ends_at = valid_loan.ends_at + 1.days
  #   assert valid_loan.pending?,  "loan should be pending after changing ends_at"
  #   assert valid_loan.valid?,    "loan should be valid"
  # end

  it "should transition to checked_out when checked out by an attendant" do
    attendant = FactoryGirl.create(:attendant_user)
    valid_loan.approve!
    assert valid_loan.requested?,     "loan should be requested"
    assert attendant.attendant?,     "attendant should have 'attendant' role"
    valid_loan.save
    valid_loan.check_out!
    assert valid_loan.halted?,        "should not have halted transition to checked_out unless components were inventoried: #{valid_loan.halted_because.to_s}"
    valid_loan.new_check_out_inventory_record(attendant: attendant)
    valid_loan.check_out_inventory_record.inventory_details.each {|id| id.missing = false}
    valid_loan.check_out!
    refute valid_loan.halted?,       "should have transitioned to checked_out: #{valid_loan.halted_because.to_s}"
    assert valid_loan.checked_out?,  "Check out by attendant should have worked"
    assert valid_loan.out_at,        "Checked out loan should have an out timestamp"
    assert valid_loan.valid?,        "Transition to checked_out should result in a valid loan\n#{valid_loan.errors.inspect}"
  end

  it "should transition to checked_out when checked out by an admin" do
    out_attendant = FactoryGirl.create(:admin_user)
    valid_loan.approve!
    assert valid_loan.requested?,     "loan should be requested"
    assert out_attendant.attendant?, "out_attendant should have attendant role"
    valid_loan.save
    valid_loan.new_check_out_inventory_record(attendant: out_attendant)
    valid_loan.check_out_inventory_record.inventory_details.each {|id| id.missing = false}
    valid_loan.check_out!
    refute valid_loan.halted?,       "should have transitioned to checked_out: #{valid_loan.halted_because.to_s}"
    assert valid_loan.checked_out?,  "Check out by attendant should have worked"
    assert valid_loan.out_at,        "Checked out loan should have an out timestamp"
    assert valid_loan.valid?,        "Transition to checked_out should result in a valid loan\n#{valid_loan.errors.inspect}"
  end

  # non-circulating kits should not be loan-able
  it "should not be valid with with a non-circulating kit" do
    starts_at = test_kit.location.next_datetime_open
    assert test_kit.valid?
    refute test_kit.location.nil?, "location should not be nil"
    refute test_kit.location.business_hours.empty?, "location should have business hours"
    refute starts_at.nil?, "starts_at should not be nil"

    loan      = FactoryGirl.build(:loan, kit: test_kit, client: test_user, starts_at: starts_at)
    #loan.autofill_ends_at!

    refute test_kit.circulating?
    assert test_kit.valid?
    assert test_user.valid?
    assert loan.pending?
    refute loan.kit.nil?
    refute loan.kit.location.nil?
    # refute loan.ends_at.nil?
    refute loan.starts_at.nil?
    assert loan.kit.location.open_on?(loan.starts_at),  "location should be open on the starting day of the loan"
    refute loan.kit.permissions_include?(loan.client),  "client should not have permission to check out the non-circulating kit"
    refute loan.client.disabled?,                       "client should not be disabled"
    refute loan.client.suspended?,                      "client should not be suspended"
    # assert loan.kit.location.open_on?(loan.ends_at),    "location should be open on the day the loan ends"
    # assert loan.starts_at < loan.ends_at,               "the loan start date should come before the loan end date"
    refute loan.valid?, loan.errors.inspect

  end

  it "should not allow illegal transitions from pending" do
    assert valid_loan.pending?, "loan should be pending"
    assert valid_loan.valid?, "pending loan should be valid"
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_in!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_out! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.mark_lost! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.resubmit!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.unapprove! }
  end

  it "should not allow illegal transitions from pending" do
    assert valid_loan.pending?, "loan should be pending"
    valid_loan.cancel!
    assert valid_loan.valid?, "canceled loan should be valid\n#{ valid_loan.errors.inspect }"
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.approve!   }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.cancel!    }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_in!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_out! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.mark_lost! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.resubmit!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.unapprove! }
  end

  it "should not allow illegal transitions from declined" do
    assert valid_loan.pending?, "loan should be pending"
    valid_loan.decline!
    assert valid_loan.valid?, "valid loan should be valid\n#{ valid_loan.errors.inspect }"
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.approve!   }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.cancel!    }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_in!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_out! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.mark_lost! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.unapprove! }

    valid_loan.resubmit!
    assert valid_loan.pending?, "a declined loan should become pending after resubmit"
    assert valid_loan.valid?, "resubmitted loan should be valid\n#{ valid_loan.errors.inspect }"
  end

  it "should not allow illegal transitions from requested, check_out, lost, or check_in" do
    valid_loan.approve!
    assert valid_loan.valid?, "requested loan should be valid\n#{ valid_loan.errors.inspect }"
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.approve!   }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_in!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.mark_lost! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.resubmit!  }

    attendant   = FactoryGirl.create(:attendant_user)

    valid_loan.build_check_out_inventory_record(attendant: attendant, kit: valid_loan.kit)
    valid_loan.kit.components.each {|c| valid_loan.check_out_inventory_record.inventory_details << InventoryDetail.new(component: c, missing: false) }
    valid_loan.check_out!
    refute valid_loan.halted?, "transition should not have halted: #{ valid_loan.halted_because }"
    assert valid_loan.checked_out?, "loan should be checked out"
    valid_loan.valid?
    assert valid_loan.valid?, "checked out loan should be valid\n#{ valid_loan.errors.inspect }"

    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.approve!   }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.cancel!    }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_out! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.resubmit!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.unapprove! }

    valid_loan.mark_lost!
    assert valid_loan.lost?, "loan should be lost"
    assert valid_loan.valid?, "lost loan should be valid\n#{ valid_loan.errors.inspect }"
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.approve!   }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.cancel!    }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_out! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.mark_lost! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.resubmit!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.unapprove! }

    valid_loan.check_in!
    assert valid_loan.halted?, "loan should have halted on transition to checked_in: #{ valid_loan.halted_because }"
    valid_loan.build_check_in_inventory_record(attendant: attendant, kit: valid_loan.kit)
    valid_loan.kit.components.each {|c| valid_loan.check_in_inventory_record.inventory_details << InventoryDetail.new(component: c, missing: false) }
    valid_loan.check_in!
    refute valid_loan.halted?,     "loan should have transitioned to checked_in: #{ valid_loan.halted_because }"
    assert valid_loan.checked_in?, "loan should be checked in\n#{ valid_loan.errors.inspect }"
    assert valid_loan.valid?,      "checked in loan should be valid\n#{ valid_loan.errors.inspect }"
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.approve!   }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.cancel!    }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_in!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_out! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.mark_lost! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.resubmit!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.unapprove! }

  end

end
