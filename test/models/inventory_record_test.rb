require "test_helper"

describe InventoryRecord do
  before do
    @inventory_record = InventoryRecord.new
  end

  it "should assign kit based on components setters" do
    kit       = FactoryGirl.build(:kit)
    component = FactoryGirl.build(:component_with_branded_component_model, kit: kit)
    assert component.valid?, "component should be valid"
    @inventory_record.components << component
    refute @inventory_record.kit.nil?, "kit should not be nil"

    # make sure we blow up if you add a component from another kit
    other_kit       = FactoryGirl.build(:kit)
    other_component = FactoryGirl.build(:component_with_branded_component_model, kit: other_kit)
    assert_raises(InventoryRecord::MismatchingKitException) { @inventory_record.components << other_component }
  end

  # it "must be valid" do
  #   @inventory_record.valid?.must_equal true
  # end
end
