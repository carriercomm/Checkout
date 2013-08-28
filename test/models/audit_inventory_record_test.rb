require "test_helper"

describe AuditInventoryRecord do

  let(:air) do
    FactoryGirl.build(:audit_inventory_record)
  end

  it "should be valid" do
    refute air.valid?
    kit       = FactoryGirl.build(:kit)
    component = FactoryGirl.build(:component_with_branded_component_model, kit: kit)
    air.components << component
    assert air.valid?
  end

  it "should assign kit based on components setters" do
    kit       = FactoryGirl.build(:kit)
    component = FactoryGirl.build(:component_with_branded_component_model, kit: kit)
    assert component.valid?, "component should be valid"
    air.components << component
    refute air.kit.nil?, "kit should not be nil"

    # make sure we blow up if you add a component from another kit
    other_kit       = FactoryGirl.build(:kit)
    other_component = FactoryGirl.build(:component_with_branded_component_model, kit: other_kit)
    assert_raises(InventoryRecord::MismatchingKitException) { air.components << other_component }
  end


end
