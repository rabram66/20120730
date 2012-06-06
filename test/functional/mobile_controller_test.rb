require 'test_helper'

# Force mobile header
class MobileController
  def set_request_format(force_mobile=false)
    force_mobile_format
  end

  def mobile_device
    'iphone'
  end
end

class MobileControllerTest < ActionController::TestCase

  setup do
    @geocode = [33.7489954, -84.3879824]
    @location = locations(:one)
  end

  context 'from a non-mobile browser' do
    setup do
      def @controller.is_mobile_device?
        false
      end
    end
    
    should 'redirect request for mobile detail page to non-mobile detail page' do
      get :detail, :id => @location.reference
      assert_response :redirect
      assert_equal @request.url.gsub("mobile/detail/","details/"), @response.headers['Location']
    end
  end

  context 'from a mobile browser' do

    should "get index" do
      get :index
      assert_response :success
      assert_template :index
    end

    should "get list" do
      Place.expects(:find_by_geocode).returns([])
      DealSet.expects(:near).returns([])
      get :list
      assert_response :success
      assert_template :list
    end

    should "get detail" do
      Tweet.expects(:user_status).with('wafflehouse').returns(Tweet.new(:text => 'foo', :created_at => Time.now))
      Tweet.expects(:geosearch).with("@#{@location.twitter_name}",@location.coordinates, 5, 20).returns([])
      Tweet.expects(:geosearch).with("\"#{@location.name}\"",@location.coordinates, 5, 20).returns([])
      Tweet.expects(:non_geosearch).with("@#{@location.twitter_name}", 20).returns([])
      Tweet.expects(:non_geosearch).with("\"#{@location.name}\"", 20).returns([])
      get :detail, :id => @location.slug
      assert_response :success
      assert_template :detail
    end
  
    should "get deals" do
      DealSet.expects(:near).returns([])
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
      Tweet.expects(:search).returns([])
      get :event, :id => @event.id
      assert_response :success
      assert_template :event
    end

  end

end