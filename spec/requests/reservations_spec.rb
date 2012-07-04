require 'spec_helper'

describe ReservationsController do

  describe "with user not logged in" do
    it "should redirect to the login page" do
      get reservations_path
      response.should redirect_to(new_user_session_path)
    end
  end

  describe "with user logged in" do
    let(:user) { FactoryGirl.create(:user) }

    it "should get index" do
      as_user(user) do
        visit reservations_path
        current_path.should == reservations_path
      end
    end

    it "should create reservation for logged in user with model" do
      as_user(user) do
        model = FactoryGirl.create(:model)
        visit new_model_reservation_path(:model_id => model.id)
        # should not get redirected
        current_path.should == new_model_reservation_path(:model_id => model.id)
      end
    end

  end

end
