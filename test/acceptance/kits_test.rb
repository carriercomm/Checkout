require 'minitest_helper'

describe "User Browsing Kits Acceptance Test" do
  let(:user) { FactoryGirl.create(:user) }
  let(:kit) do
    model1     = FactoryGirl.create(:component_model_with_brand)
    component1 = FactoryGirl.build(:component, component_model: model1, asset_tag: "AAA")
    FactoryGirl.create(:checkoutable_kit_with_location, components: [component1])
  end

  it "should not display new/edit buttons on index page" do
    as_user(user) do
      assert kit.valid?
      visit kits_path
      assert current_path == kits_path
      assert page.has_content? KitDecorator.decorate(kit).asset_tags
      assert page.has_no_selector? "a.btn-new-kit"
      assert page.has_no_selector? "a.btn-edit-kit"
    end
  end

  it "should not display edit/delete buttons on show page" do
    as_user(user) do
      assert kit.valid?
      visit kit_path(kit)
      assert current_path == kit_path(kit)
      assert page.has_content? KitDecorator.decorate(kit).asset_tags
      assert page.has_no_selector? "a.btn-edit-kit"
      assert page.has_no_selector? "a.btn-delete-kit"
    end
  end

  it "should redirect on edit page" do
    as_user(user) do
      assert kit.valid?
      visit edit_kit_path(kit)
      assert current_path != edit_kit_path(kit)
      assert page.has_content? "You are not authorized to access this page."
    end
  end

end

describe "Admin Browsing Kits Acceptance Test" do
  let(:admin) do
    role = FactoryGirl.create(:role, name:"admin")
    FactoryGirl.create(:user, roles:[role])
  end
  let(:kit) do
    model1     = FactoryGirl.create(:component_model_with_brand)
    component1 = FactoryGirl.build(:component, component_model: model1, asset_tag: "AAA")
    location1  = FactoryGirl.build(:location)
    FactoryGirl.create(:checkoutable_kit_with_location, components: [component1])
  end

  it "should display new/edit buttons on index page" do
    as_user(admin) do
      assert kit.valid?
      visit kits_path
      assert current_path == kits_path
      assert page.has_content? KitDecorator.decorate(kit).asset_tags
      assert page.has_selector? "a.btn-new-kit"
      assert page.has_selector? "a.btn-edit-kit"
    end
  end

  it "should display edit/delete buttons on show page" do
    as_user(admin) do
      assert kit.valid?
      visit kit_path(kit)
      assert current_path == kit_path(kit)
      assert page.has_content? KitDecorator.decorate(kit).asset_tags
      assert page.has_selector? "a.btn-edit-kit"
      assert page.has_selector? "a.btn-delete-kit"
    end
  end

  it "should allow editing" do
    as_user(admin) do
      assert kit.valid?
      visit edit_kit_path(kit)
      assert current_path == edit_kit_path(kit)
      assert find_field("kit_location_id").value.to_i == kit.location.id
      check("kit_tombstoned")
      click_on("Update Kit")
      assert page.has_content? "Kit was successfully updated."
    end
  end

end
