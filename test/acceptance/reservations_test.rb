require 'minitest_helper'

describe "Guest Reservation Acceptance Test" do
  it "should redirect guests to the login page" do
    visit reservations_path
    assert page.has_content? "Sign In"
  end
end

describe "User Reservation Acceptance Test" do
  let(:user) { FactoryGirl.create(:user) }

  it "should get index" do
    as_user(user) do
      visit reservations_path
      assert page.has_content? "Reservations"
    end
  end

  # it "should create reservation for logged in user with model" do
  #   as_user(user) do
  #     model = FactoryGirl.create(:model)
  #     visit new_model_reservation_path(:model_id => model.id)
  #     # should not get redirected
  #     current_path.should == new_model_reservation_path(:model_id => model.id)
  #   end
  # end
end
