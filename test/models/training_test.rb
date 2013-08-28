require "test_helper"

describe Training do

  it "must be valid" do
    training = FactoryGirl.build(:training)
    refute training.valid?

    component_model = FactoryGirl.build(:branded_component_model)
    assert component_model.valid?

    user = FactoryGirl.build(:user)
    assert user.valid?

    training.component_model = component_model
    refute training.valid?

    training.component_model = nil
    training.user = user
    refute training.valid?

    training.component_model = component_model
    assert training.valid?
  end

end
