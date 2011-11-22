require 'test_helper'

class AdTrackingsControllerTest < ActionController::TestCase
  setup do
    @ad_tracking = ad_trackings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ad_trackings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ad_tracking" do
    assert_difference('AdTracking.count') do
      post :create, ad_tracking: @ad_tracking.attributes
    end

    assert_redirected_to ad_tracking_path(assigns(:ad_tracking))
  end

  test "should show ad_tracking" do
    get :show, id: @ad_tracking.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ad_tracking.to_param
    assert_response :success
  end

  test "should update ad_tracking" do
    put :update, id: @ad_tracking.to_param, ad_tracking: @ad_tracking.attributes
    assert_redirected_to ad_tracking_path(assigns(:ad_tracking))
  end

  test "should destroy ad_tracking" do
    assert_difference('AdTracking.count', -1) do
      delete :destroy, id: @ad_tracking.to_param
    end

    assert_redirected_to ad_trackings_path
  end
end
