require "test_helper"

describe Covenant do
  before do
    @covenant = Covenant.new
  end

  it "must be valid" do
    @covenant.valid?.must_equal true
  end
end
