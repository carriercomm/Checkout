require 'minitest_helper'

describe "User Browsing Brands Acceptance Test" do
  let(:user) { FactoryGirl.create(:user) }
  let(:brand) { FactoryGirl.create(:brand) }

  it "should not display new/edit buttons on index page" do
    as_user(user) do
      assert brand.valid?
      visit brands_path
#fails
      assert current_path == brands_path
      assert page.has_content? brand.name
      assert page.has_no_selector? "a.btn-new-brand"
      assert page.has_no_selector? "a.btn-edit-brand"
    end
  end

  it "should not display edit/delete buttons on show page" do
    as_user(user) do
      assert brand.valid?
      visit brand_path(brand)
      assert current_path == brand_path(brand)
      assert page.has_content? brand.name
      assert page.has_no_selector? "a.btn-edit-brand"
      assert page.has_no_selector? "a.btn-delete-brand"
    end
  end

  it "should redirect on edit page" do
    as_user(user) do
      assert brand.valid?
      visit edit_brand_path(brand)
      assert current_path != edit_brand_path(brand)
      assert page.has_content? "You are not authorized to access this page."
    end
  end

end

describe "Admin Browsing Brands Acceptance Test" do
  let(:admin) do
    role = FactoryGirl.create(:role, name:"admin")
    FactoryGirl.create(:user, roles:[role])
  end
  let(:brand) { FactoryGirl.create(:brand) }

  it "should display new/edit buttons on index page" do
    as_user(admin) do
      assert brand.valid?
      visit brands_path
      assert current_path == brands_path
      assert page.has_content? brand.name
      assert page.has_selector? "a.btn-new-brand"
      assert page.has_selector? "a.btn-edit-brand"
    end
  end

  it "should allow editing" do
    as_user(admin) do
      assert brand.valid?
      visit edit_brand_path(brand)
      assert current_path == edit_brand_path(brand)
      assert find_field("brand_name").value == brand.name
      fill_in("brand_name", with: "Pound Cake")
      click_on("Update Brand")
      assert page.has_content? "Brand was successfully updated."
    end
  end

end

