require "test_helper"

describe Permission do

  it "must be valid" do
    component = FactoryGirl.create(:component_with_branded_component_model)
    assert component.valid?

    kit = FactoryGirl.build(:kit_with_location)
    kit.components << component
    kit.save
    assert kit.valid?

    group = FactoryGirl.build(:group)
    assert group.valid?

    permission = FactoryGirl.build(:permission)
    permission.group = group
    permission.kit = kit
    assert permission.valid?
  end

end
