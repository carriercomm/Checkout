require "test_helper"

describe Settings do
  before do
    @settings = Settings.new
  end

  it "must be valid" do
    @settings.valid?.must_equal true
  end
end
