module ControllerMacros
  def login_user
    @user ||= FactoryGirl.create :user
    sign_in @user # method from devise:TestHelpers
  end
end
