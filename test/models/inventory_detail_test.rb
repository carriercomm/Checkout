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

end
