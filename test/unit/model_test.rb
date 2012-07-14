require 'test_helper'

describe Model do

  it "should support checkoutable and non-checkoutable kits" do
    component = FactoryGirl.build(:component_with_model)

    component.valid?
    puts "-------"
    puts component.errors.inspect
    puts component.inspect
    puts "-------"
    component.must_be :valid?
    
    #model.component.count.must_equal(1)

  end

end
