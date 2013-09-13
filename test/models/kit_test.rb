require "test_helper"

describe Kit do

  let(:non_circulating_kit) do
    FactoryGirl.build(:kit_with_location)
  end

  let(:circulating_kit) do
    FactoryGirl.build(:circulating_kit_with_location)
  end

  # TODO: fix me
  # it "should be removed from circulation when tombstoned" do
  #   component = FactoryGirl.build(:component_with_branded_component_model)
  #   circulating_kit.components << component
  #   assert circulating_kit.valid?, "kit should be valid \n#{ circulating_kit.errors.inspect }"
  #   refute circulating_kit.tombstoned
  #   assert circulating_kit.circulating?
  #   circulating_kit.tombstoned = true
  #   refute circulating_kit.circulating?
  # end

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
