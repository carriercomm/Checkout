require 'minitest_helper'

describe "User Browsing Budgets Acceptance Test" do
  let(:user) { FactoryGirl.create(:user) }
  let(:budget) { FactoryGirl.create(:budget) }

  it "should redirect index page" do
    as_user(user) do
      assert budget.valid?
      visit budgets_path
      assert current_path != budgets_path
      assert page.has_content? "You are not authorized to access this page."
    end
  end

  it "should redirect show page" do
    as_user(user) do
      assert budget.valid?
      visit budget_path(budget)
      assert current_path != budget_path(budget)
      assert page.has_content? "You are not authorized to access this page."
    end
  end

  it "should redirect edit page" do
    as_user(user) do
      assert budget.valid?
      visit edit_budget_path(budget)
      assert current_path != edit_budget_path(budget)
      assert page.has_content? "You are not authorized to access this page."
    end
  end

end

describe "Admin Browsing Budgets Acceptance Test" do
  let(:admin) do
    role = FactoryGirl.create(:role, name:"admin")
    FactoryGirl.create(:user, roles:[role])
  end
  let(:budget) { FactoryGirl.create(:budget) }

  it "should display new/edit buttons on index page" do
    as_user(admin) do
      assert budget.valid?
      visit budgets_path
      assert current_path == budgets_path
      assert page.has_content? budget.name
      assert page.has_selector? "a.btn-new"
      assert page.has_selector? "a.btn-edit-budget"
    end
  end

  it "should allow editing" do
    as_user(admin) do
      assert budget.valid?
      visit edit_budget_path(budget)
      assert current_path == edit_budget_path(budget)
      assert find_field("budget_name").value == budget.name
      fill_in("budget_name", with: "Pound Cake")
      click_on("Update Budget")
      assert page.has_content? "Budget was successfully updated."
    end
  end

end

