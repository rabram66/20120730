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

  context 'from a mobile browser' do

    should "get index" do
      get :index
      assert_response :success
      assert_template :index
    end

    should "get list" do
      Place.expects(:find_by_geocode).returns([])
      Deal.expects(:find_by_geocode).returns([])
      get :list
      assert_response :success
      assert_template :list
    end

    should "get detail" do
      Tweet.expects(:user_status).with('wafflehouse').returns(Tweet.new(:text => 'foo', :created_at => Time.now))
      Tweet.expects(:mentions).returns([])
      get :detail, :id => @location.reference
      assert_response :success
      assert_template :detail
    end
  
    should "get deals" do
      Deal.expects(:find_by_geocode).returns([])
      get :deals
      assert_response :success
      assert_template :deals
    end

    should "get events" do
      get :events, :lat => @geocode.first, :lng => @geocode.last
      assert_response :success
      assert_template :events
    end

    should "get event" do
      @event = events(:promoted)
      get :events, :id => @event.id
      assert_response :success
      assert_template :event
    end

  end

end