require 'minitest_helper'

describe "User Browsing Categories Acceptance Test" do
  let(:user) { FactoryGirl.create(:user) }
  let(:category) { FactoryGirl.create(:category) }

  it "should not display new/edit buttons on index page" do
    as_user(user) do
      assert category.valid?
      visit categories_path
      assert current_path == categories_path
      assert page.has_content? category.name
      assert page.has_no_selector? "a.btn-new-category"
      assert page.has_no_selector? "a.btn-edit-category"
    end
  end

  it "should not display edit/delete buttons on show page" do
    as_user(user) do
      assert category.valid?
      visit category_path(category)
      assert current_path == category_path(category)
      assert page.has_content? category.name
      assert page.has_no_selector? "a.btn-edit-category"
      assert page.has_no_selector? "a.btn-delete-category"
    end
  end

  it "should redirect on edit page" do
    as_user(user) do
      assert category.valid?
      visit edit_category_path(category)
      assert current_path != edit_category_path(category)
      assert page.has_content? "You are not authorized to access this page."
    end
  end

end

describe "Admin Browsing Categories Acceptance Test" do
  let(:admin) do
    role = FactoryGirl.create(:role, name:"admin")
    FactoryGirl.create(:user, roles:[role])
  end
  let(:category) { FactoryGirl.create(:category) }

  it "should display new/edit buttons on index page" do
    as_user(admin) do
      assert category.valid?
      visit categories_path
      assert current_path == categories_path
      assert page.has_content? category.name
      assert page.has_selector? "a.btn-new-category"
      assert page.has_selector? "a.btn-edit-category"
    end
  end

  it "should display edit/delete buttons on show page" do
    as_user(admin) do
      assert category.valid?
      visit category_path(category)
      assert current_path == category_path(category)
      assert page.has_content? category.name
      assert page.has_selector? "a.btn-edit-category"
      assert page.has_selector? "a.btn-delete-category"
    end
  end

  it "should allow editing" do
    as_user(admin) do
      assert category.valid?
      visit edit_category_path(category)
      assert current_path == edit_category_path(category)
      assert find_field("category_name").value == category.name
      fill_in("category_name", with: "Pound Cake")
      click_on("Update Category")
      assert page.has_content? "Category was successfully updated."
    end
  end

end

