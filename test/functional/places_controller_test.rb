require 'test_helper'

class PlacesControllerTest < ActionController::TestCase

  setup do
    @location = locations(:one)
  end

  context 'GET index' do
    should "succeed" do
      Geocoder.expects(:coordinates).returns([0.0,0.0])
      Place.expects(:find_by_geocode).with([33.7489954, -84.3879824],LocationCategory::EatDrink.types).returns([])
      Event.expects(:upcoming_near).returns([])
      Deal.expects(:find_by_geocode).with([33.7489954, -84.3879824]).returns(DealSet.new([]))
    
      get :index
      assert_not_nil assigns(:locations)
      assert_response :success
      assert_template :index
    end
  end

  context 'GET details for location' do
    should "succeed" do
      Tweet.expects(:user_status).with(@location.twitter_name).returns(nil)
      Tweet.expects(:mentions).with(@location.twitter_name,40).returns([])
      get :details, :reference => @location.reference
      assert_response :success
      assert_template :details
    end
  end
  
  context 'GET details for Google place' do
    should "succeed" do
      place           = Place.new
      place.name      = 'Bozos'
      place.address   = '2578 Binghamton Drive'
      place.city      = 'Atlanta'
      place.latitude  = 33.7489954
      place.longitude = -84.3879824
      Place.expects(:find_by_reference).with('123').returns(place)
      Tweet.expects(:geosearch).with("\"#{place.name}\"",place.coordinates,5,40).returns([])
      get :details, :reference => "123"
      assert_response :success
      assert_template :details
    end
  end
  
  context 'XHR POST recent tweeters' do

    should 'fetch twitter user statuses from cache' do
      names = %w(foo bar baz)
      names.each do |name|
        Tweet.expects(:cached_user_status).with(name).returns(nil)
      end
      xhr :post, :recent_tweeters, :n => names
    end

    should 'return twitter names with recent tweets' do
      names = %w(foo bar baz fizz)
      Tweet.expects(:cached_user_status).with("foo").returns(Tweet.new(:created_at => 4.hours.ago))
      Tweet.expects(:cached_user_status).with("bar").returns(Tweet.new(:created_at => 2.days.ago))
      Tweet.expects(:cached_user_status).with("baz").returns(Tweet.new(:created_at => 3.minutes.ago))
      Tweet.expects(:cached_user_status).with("fizz").returns(nil)
      xhr :get, :recent_tweeters, :n => names
      assert_equal ["foo","baz"], JSON.parse(response.body)
    end

  end
end
