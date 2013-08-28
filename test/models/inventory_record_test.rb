require "test_helper"

describe InventoryRecord do

  it "should blow up" do
    assert_raises(InventoryRecord::AbstractBaseClassException) { InventoryRecord.new }
  end

end
