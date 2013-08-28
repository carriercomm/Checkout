require "test_helper"

describe User do
  let(:user) { FactoryGirl.create(:user) }

  it "must be valid" do
    user.valid?.must_equal true
  end
end
