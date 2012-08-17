require "minitest_helper"

# To be handled correctly this spec must end with "Acceptance Test"
describe "Guest Browsing Models Acceptance Test" do

  it "should redirect guests" do
    visit models_path
    assert page.has_content? "Sign In"

    visit checkoutable_models_path
    assert page.has_content? "Sign In"
  end

end

describe " Browsing Models Acceptance Test" do
  let(:user) { FactoryGirl.create(:user) }

  it "should redirect guests" do
    visit models_path
    assert page.has_content? "Sign In"
  end

end
