require 'test_helper'

# Force mobile header
class MobileController
  def set_request_format(force_mobile=false)
    force_mobile_format
  end
end

class MobileControllerTest < ActionController::TestCase

  setup do
    @geocode = [33.7489954, -84.3879824]
    @location = locations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_template :index
  end

  test "should get list" do
    get :list
    assert_response :success
    assert_template :list
  end

  test "should get detail" do
    get :detail, :id => @location.reference
    assert_response :success
    assert_template :detail
  end
  
  test "should get deals" do
    get :deals
    assert_response :success
    assert_template :deals
  end

  test "should get events" do
    get :events, :lat => @geocode.first, :lng => @geocode.last
    assert_response :success
    assert_template :events
  end

end