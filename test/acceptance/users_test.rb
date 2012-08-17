require "minitest_helper"

# To be handled correctly this spec must end with "Acceptance Test"
describe "Client Browsing Users Acceptance Test" do
  let(:user) { FactoryGirl.create(:user) }

  it "should deny access to user management" do
    as_user(user) do
      visit users_path
      assert page.has_content? "You are not authorized to access this page."

      visit new_user_path
      assert page.has_content? "You are not authorized to access this page."
    end
  end

end

# To be handled correctly this spec must end with "Acceptance Test"
describe "Admin Browsing Users Acceptance Test" do
  let(:admin_user) do
    admin_role = FactoryGirl.create(:role, name: "admin")
    FactoryGirl.create(:user, roles: [admin_role])
  end

  it "should allow admin access to user list" do
    as_user(admin_user) do
      visit users_path
      assert page.has_content? "Users"
    end
  end

  it "should allow admin access to view and edit user" do
    user = FactoryGirl.create(:user)
    as_user(admin_user) do
      visit user_path(user)
      assert page.has_content? "Edit User"
    end
  end

  it "should allow an admin to create users" do
    as_user(admin_user) do
      visit new_user_path
      fill_in "user_username", :with => "Roland Barthes"
      fill_in "user_email", :with => "rolandb@dxarts.washington.edu"
      click_button "Create User"
      assert page.has_content? "User was successfully created."
    end
  end

end
