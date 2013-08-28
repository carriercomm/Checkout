require "test_helper"

describe Kit do

  let(:non_circulating_kit) do
    FactoryGirl.build(:kit_with_location)
  end

  let(:circulating_kit) do
    FactoryGirl.build(:circulating_kit_with_location)
  end

  it "should be removed from circulation when tombstoned" do
    assert circulating_kit.valid?
    reftue circulating_kit.tombstoned
    assert circulating_kit.circulating?
    circulating_kit.tombstoned = true
    refute circulating_kit.circulating?
  end
end
