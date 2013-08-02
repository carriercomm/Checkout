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

  let(:user) do
    FactoryGirl.create(:user)
  end

  let(:valid_loan) do
    group = FactoryGirl.create(:group)
    group.users << user
    group.kits << kit

    starts_at       = kit.location.next_time_open.to_datetime
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
    assert loan.valid?,            "loan should be valid\n#{loan.errors.inspect}"
    loan
  end


  # editing a loan should force it to be re-approved
  # ends_at should be the next available check in day after the default checkout duration (taking holidays and weekends in to account)

  it "should auto-approve a valid pending loan with nil end date" do
    valid_loan.approve!
    assert valid_loan.approved?, "loan should be approved"
    assert valid_loan.ends_at,   "loan should have an end date after automatic approval"
  end

  it "should update ends_at when starts_at is changed" do
    valid_loan.approve!
    assert valid_loan.approved?, "loan should be approved"
    assert valid_loan.ends_at,   "loan should have an end date after automatic approval"
    old_ends_at   = valid_loan.ends_at
    time          = valid_loan.starts_at + 1.days
    time          = Time.local(time.year, time.month, time.day, time.hour, time.min, time.sec)
    new_starts_at = valid_loan.location.next_time_open(time)
    valid_loan.starts_at = new_starts_at
    assert valid_loan.pending?,  "loan should change to pending after altering starts_at"
    #assert valid_loan.approved?, "loan should be approved after only changing starts_at"
    refute_equal(valid_loan.ends_at, old_ends_at, "loan ends_at should be automatically adjusted when starts_at is changed")
  end

  it "should transition to pending when ends_at is changed and the resulting checkout length is non-default" do
    valid_loan.approve!
    assert valid_loan.approved?, "loan should be approved"
    valid_loan.ends_at = valid_loan.ends_at + 1.days
    assert valid_loan.pending?, "loan should be pending after changing ends_at"
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

  it "should not allow illegal transitions" do
    assert valid_loan.pending?, "loan should be pending"
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_in!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_out! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.mark_lost! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.resubmit!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.unapprove! }

    canceled_loan = valid_loan.dup
    canceled_loan.cancel!
    assert_raises(Workflow::NoTransitionAllowed) { canceled_loan.approve!   }
    assert_raises(Workflow::NoTransitionAllowed) { canceled_loan.cancel!    }
    assert_raises(Workflow::NoTransitionAllowed) { canceled_loan.check_in!  }
    assert_raises(Workflow::NoTransitionAllowed) { canceled_loan.check_out! }
    assert_raises(Workflow::NoTransitionAllowed) { canceled_loan.mark_lost! }
    assert_raises(Workflow::NoTransitionAllowed) { canceled_loan.resubmit!  }
    assert_raises(Workflow::NoTransitionAllowed) { canceled_loan.unapprove! }

    declined_loan = valid_loan.dup
    declined_loan.decline!
    assert_raises(Workflow::NoTransitionAllowed) { declined_loan.approve!   }
    assert_raises(Workflow::NoTransitionAllowed) { declined_loan.cancel!    }
    assert_raises(Workflow::NoTransitionAllowed) { declined_loan.check_in!  }
    assert_raises(Workflow::NoTransitionAllowed) { declined_loan.check_out! }
    assert_raises(Workflow::NoTransitionAllowed) { declined_loan.mark_lost! }
    assert_raises(Workflow::NoTransitionAllowed) { declined_loan.unapprove! }

    declined_loan.resubmit!
    assert declined_loan.pending?, "a declined loan should become pending after resubmit"

    valid_loan.approve!
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.approve!   }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_in!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.mark_lost! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.resubmit!  }

    attendant = FactoryGirl.build(:attendant_user)
    valid_loan.check_out!(attendant)
    assert valid_loan.checked_out?, "loan should be checked out"
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.approve!   }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.cancel!    }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_out! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.resubmit!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.unapprove! }

    valid_loan.mark_lost!
    assert valid_loan.lost?, "loan should be lost"
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.approve!   }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.cancel!    }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_out! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.mark_lost! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.resubmit!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.unapprove! }

    valid_loan.check_in!(attendant)
    assert valid_loan.checked_in?, "loan should be checked in"
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.approve!   }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.cancel!    }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_in! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.check_out! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.mark_lost! }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.resubmit!  }
    assert_raises(Workflow::NoTransitionAllowed) { valid_loan.unapprove! }


  end

end
