require 'test_helper'

class LocationsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user1)
    @location = locations(:one)
  end

  test "should get index" do
    get :index
    assert_not_nil assigns(:locations)
    assert_response :success
    assert_template :index
  end

  test "should get details" do
    get :details, :reference => @location.reference
    assert_response :success
    assert_template :details
  end
  
  test "should get details for place" do
    get :details, :reference => "CnRlAAAA2ffQcM3KlWgJpTl9JMGMDEiigid16ZX-IFPsm_FujEP7grL7YvGERZimBcHwHLg6CK9y0oNUkHrrXm57zyEky-YQWejxLfVlORoXpAhvRuWGYaFbqMLROC0_Renf4zBG1QHfkPeMu0VU9dMG0H4DtRIQwQUubtpqcFICzkXzlogoOxoUDJxhFN9H1sCOlkCLhEiqMl-eMOQ"
    assert_response :success
    assert_template :details
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_template :new
  end

  test "should create location" do
    assert_difference('Location.count') do
      post :create, :location => @location.attributes
    end
    assert_redirected_to location_path(assigns(:location))
  end

  test "should show location" do
    get :show, :id => @location.to_param
    assert_response :success
    assert_template :show
  end

  test "should get edit" do
    get :edit, :id => @location.to_param
    assert_response :success
    assert_template :edit
  end

  test "should update location" do
    put :update, :id => @location.to_param, :location => @location.attributes
    assert_redirected_to location_path(assigns(:location))
  end

  test "should destroy location" do
    assert_difference('Location.count', -1) do
      delete :destroy, :id => @location.to_param
    end
    assert_redirected_to locations_path
  end

  test 'should load deals' do
    get :load_deals
    assert_response :success
    assert_template :deals
    assert_select 'div.deal_link'
  end

end
