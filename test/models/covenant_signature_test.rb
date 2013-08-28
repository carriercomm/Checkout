require "test_helper"

describe CovenantSignature do
  before do
    @covenant_signature = CovenantSignature.new
  end

  it "must be valid" do
    @covenant_signature.valid?.must_equal true
  end
end
