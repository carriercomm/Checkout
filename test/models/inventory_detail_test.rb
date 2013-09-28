require "test_helper"

describe InventoryDetail do

  it "must be valid" do
    id = FactoryGirl.build(:inventory_detail)
    refute id.valid?        # no component

    component = FactoryGirl.build(:component_with_branded_component_model)
    id.component = component
    refute id.valid?        # no inventory record

    inventory_record = FactoryGirl.build(:audit_inventory_record)
    id.component = nil
    id.inventory_record = inventory_record
    refute id.valid?        # inventory record, but no component

    id.component = component
    assert id.valid?, id.errors.inspect

  end

end
