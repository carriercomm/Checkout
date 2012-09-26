require "minitest_helper"

# To be handled correctly this spec must end with "Acceptance Test"
describe "Guest Browsing Component Models Acceptance Test" do

  it "should redirect guests" do
    visit component_models_path
    assert page.has_content? "Sign In"

    visit checkoutable_component_models_path
    assert page.has_content? "Sign In"
  end

end

describe "User Browsing Component Models Acceptance Test" do
  let(:user) { FactoryGirl.create(:user) }
  let(:component_model) do
    model1     = FactoryGirl.create(:branded_component_model)
    component1 = FactoryGirl.build(:component, component_model: model1, asset_tag: "AAA")
    model1
  end

  it "should not display new/edit buttons on index page" do
    as_user(user) do
      assert component_model.valid?
      visit component_models_path
      assert current_path == component_models_path
      assert page.has_content? component_model.name
      assert page.has_no_selector? "a.btn-new"
      assert page.has_no_selector? "a.btn-edit-component-model"
    end
  end

  it "should not display edit/delete buttons on show page" do
    as_user(user) do
      assert component_model.valid?
      visit component_model_path(component_model)
      assert current_path == component_model_path(component_model)
      assert page.has_content? component_model.name
      assert page.has_no_selector? "a.btn-edit-component-model"
      assert page.has_no_selector? "a.btn-delete-component-model"
    end
  end

  it "should redirect on edit page" do
    as_user(user) do
      assert component_model.valid?
      visit edit_component_model_path(component_model)
      assert current_path != edit_component_model_path(component_model)
      assert page.has_content? "You are not authorized to access this page."
    end
  end

end


describe "Admin Browsing Component Models Acceptance Test" do
  let(:admin) do
    role = FactoryGirl.create(:role, name:"admin")
    FactoryGirl.create(:user, roles:[role])
  end
  let(:component_model) do
    model1     = FactoryGirl.create(:branded_component_model)
    component1 = FactoryGirl.build(:component, component_model: model1, asset_tag: "AAA")
    model1
  end

  it "should display new/edit buttons on index page" do
    as_user(admin) do
      assert component_model.valid?
      visit component_models_path
      assert current_path == component_models_path
      assert page.has_content? component_model.name
      assert page.has_selector? "a.btn-new"
      assert page.has_selector? "a.btn-edit-component-model"
    end
  end

  it "should display edit/delete buttons on show page" do
    as_user(admin) do
      assert component_model.valid?
      visit component_model_path(component_model)
      assert current_path == component_model_path(component_model)
      assert page.has_content? component_model.name
      assert page.has_selector? "a.btn-edit-component-model"
      assert page.has_selector? "a.btn-delete-component-model"
    end
  end

  # TODO: beef this up to test validations
  # TODO: test modal dialogues
  it "should allow editing" do
    as_user(admin) do
      assert component_model.valid?
      visit edit_component_model_path(component_model)
      assert current_path == edit_component_model_path(component_model)
      assert find_field("component_model_name").value == component_model.name
      check("component_model_training_required")
      click_on("Update Model")
      assert page.has_content? "Model was successfully updated."
    end
  end

end
