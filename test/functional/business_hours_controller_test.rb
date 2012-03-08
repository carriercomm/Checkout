require 'test_helper'

class BusinessHoursControllerTest < ActionController::TestCase
  setup do
    @business_hour = business_hours(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:business_hours)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create business_hour" do
    assert_difference('BusinessHour.count') do
      post :create, business_hour: @business_hour.attributes
    end

    assert_redirected_to business_hour_path(assigns(:business_hour))
  end

  test "should show business_hour" do
    get :show, id: @business_hour
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @business_hour
    assert_response :success
  end

  test "should update business_hour" do
    put :update, id: @business_hour, business_hour: @business_hour.attributes
    assert_redirected_to business_hour_path(assigns(:business_hour))
  end

  test "should destroy business_hour" do
    assert_difference('BusinessHour.count', -1) do
      delete :destroy, id: @business_hour
    end

    assert_redirected_to business_hours_path
  end
end
