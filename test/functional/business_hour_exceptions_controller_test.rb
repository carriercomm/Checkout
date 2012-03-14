require 'test_helper'

class BusinessHourExceptionsControllerTest < ActionController::TestCase
  setup do
    @business_hour_exception = business_hour_exceptions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:business_hour_exceptions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create business_hour_exception" do
    assert_difference('BusinessHourException.count') do
      post :create, business_hour_exception: @business_hour_exception.attributes
    end

    assert_redirected_to business_hour_exception_path(assigns(:business_hour_exception))
  end

  test "should show business_hour_exception" do
    get :show, id: @business_hour_exception
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @business_hour_exception
    assert_response :success
  end

  test "should update business_hour_exception" do
    put :update, id: @business_hour_exception, business_hour_exception: @business_hour_exception.attributes
    assert_redirected_to business_hour_exception_path(assigns(:business_hour_exception))
  end

  test "should destroy business_hour_exception" do
    assert_difference('BusinessHourException.count', -1) do
      delete :destroy, id: @business_hour_exception
    end

    assert_redirected_to business_hour_exceptions_path
  end
end
