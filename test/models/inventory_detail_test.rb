require "test_helper"

describe InventoryDetail do

  it "must be valid" do
    id = FactoryGirl.build(:inventory_detail)
    refute id.valid?

    component = FactoryGirl.build(:component_with_branded_component_model)
    id.component = component
    refute id.valid?

    inventory_record = FactoryGirl.build(:audit_inventory_record)
    id.component = nil
    id.inventory_record = inventory_record
    refute id.valid?

    id.component = component
    assert id.valid?

  end

  it "should populate the kit into the inventory record before saving" do
    ir        = FactoryGirl.build(:audit_inventory_record)
    component = FactoryGirl.build(:component_with_branded_component_model)
    kit       = FactoryGirl.build(:kit_with_location)
    kit.components << component
    kit.save
    assert kit.valid?, "kit should be valid: \n#{kit.errors.inspect}"
    assert component.valid?

    id        = FactoryGirl.build(:inventory_detail, component: component, inventory_record: ir)
    refute id.component_id.nil?
    assert ir.kit.nil?, "kit should be nil"

    assert id.valid?
    refute ir.valid?, "inventory_record should not be valid"

    assert ir.save, "inventory record should save"
    assert inventory_record.kit, "inventory_record should have a kit"

  end
end
