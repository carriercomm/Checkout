require 'minitest_helper'

describe "User Browsing Kits Acceptance Test" do
  let(:user) { FactoryGirl.create(:user) }
  let(:kit) do
    component1 = FactoryGirl.build(:component_with_branded_component_model, asset_tag: "AAA")
    FactoryGirl.create(:checkoutable_kit_with_location, components: [component1])
  end

  it "should not display new/edit buttons on index page" do
    as_user(user) do
      assert kit.valid?
      visit kits_path
      assert(current_path == kits_path)
      assert(page.has_content? KitDecorator.decorate(kit).asset_tags)
      assert(page.has_no_selector? "a.btn-new")
      assert(page.has_no_selector? "a.btn-edit-kit")
    end
  end

  it "should not display edit/delete buttons on show page" do
    as_user(user) do
      assert kit.valid?
      visit kit_path(kit)
      assert(current_path == kit_path(kit))
      assert(page.has_content? KitDecorator.decorate(kit).asset_tags)
      assert(page.has_no_selector? "a.btn-edit-kit")
      assert(page.has_no_selector? "a.btn-delete-kit")
    end
  end

  it "should redirect on edit page" do
    as_user(user) do
      assert kit.valid?
      visit(edit_kit_path(kit))
      assert(current_path != edit_kit_path(kit))
      assert(page.has_content? "You are not authorized to access this page.")
    end
  end

end

describe "Admin Browsing Kits Acceptance Test" do
  let(:admin) do
    role = FactoryGirl.create(:role, name:"admin")
    FactoryGirl.create(:user, roles:[role])
  end
  let(:kit) do
    model1     = FactoryGirl.create(:branded_component_model)
    component1 = FactoryGirl.build(:component, component_model: model1, asset_tag: "AAA")
    location1  = FactoryGirl.build(:location)
    FactoryGirl.create(:checkoutable_kit_with_location, components: [component1])
  end

  it "should display new/edit buttons on index page" do
    as_user(admin) do
      assert kit.valid?
      visit kits_path
      assert(current_path == kits_path)
      assert(page.has_content? KitDecorator.decorate(kit).asset_tags)
      assert(page.has_selector? "a.btn-new")
      assert(page.has_selector? "a.btn-edit-kit")
    end
  end

  it "should display edit/delete buttons on show page" do
    as_user(admin) do
      assert kit.valid?
      visit kit_path(kit)
      assert(current_path == kit_path(kit))
      assert(page.has_content? KitDecorator.decorate(kit).asset_tags)
      assert(page.has_selector? "a.btn-edit-kit")
      assert(page.has_selector? "a.btn-delete-kit")
    end
  end

=begin
  it "should create new kits from existing resources" do
    Capybara.current_driver = Capybara.javascript_driver
    location  = FactoryGirl.create(:location, name: "Krypton")
    budget    = BudgetDecorator.decorate(FactoryGirl.create(:budget))
    model     = FactoryGirl.create(:branded_component_model)
    as_user(admin) do
      visit new_kit_path
      assert current_path == new_kit_path
      select(location.name, :from => 'kit_location_id')
      select(budget.to_s, :from => 'kit_budget_id')
      # exercising the select2 widget here :P
      find(".select2-choice").click
      find(".select2-focused").set(model.name)
      find(".select2-result").find("li").click
      click_on("Create Kit")
      assert(page.has_content? "Kit was successfully created.")
    end
    Capybara.current_driver = Capybara.default_driver
  end
=end

  it "should allow editing" do
    as_user(admin) do
      assert kit.valid?
      visit(edit_kit_path(kit))
      assert(current_path == edit_kit_path(kit))
      assert(find_field("kit_location_id").value.to_i == kit.location.id)
      check("kit_tombstoned")
      click_on("Update Kit")
      assert(page.has_content? "Kit was successfully updated.")
    end
  end

end
