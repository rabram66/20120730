require 'test_helper'

class PlacesControllerTest < ActionController::TestCase

  setup do
    @location = locations(:one)
  end

  test "should get index" do
    Geocoder.expects(:coordinates).returns([0.0,0.0])
    Tweet.expects(:latest).returns(nil)
    Place.expects(:find_by_geocode).with([33.7489954, -84.3879824],LocationCategory::EatDrink.types).returns([])
    Event.expects(:upcoming_near).returns([])
    Deal.expects(:find_by_geocode).with([33.7489954, -84.3879824]).returns(DealSet.new([]))
    
    get :index
    assert_not_nil assigns(:locations)
    assert_response :success
    assert_template :index
  end

  test "should get details for location" do
    Tweet.expects(:user_status).with(@location.twitter_name).returns(nil)
    Tweet.expects(:latest).with(@location.twitter_name).returns(nil)
    Tweet.expects(:mentions).with(@location.twitter_name,40).returns([])
    get :details, :reference => @location.reference
    assert_response :success
    assert_template :details
  end
  
  test "should get details for place" do
    place           = Place.new
    place.name      = 'Bozos'
    place.address   = '2578 Binghamton Drive'
    place.city      = 'Atlanta'
    place.latitude  = 33.7489954
    place.longitude = -84.3879824
    Place.expects(:find_by_reference).with('123').returns(place)
    Tweet.expects(:search).with(place.name,40).returns([])
    get :details, :reference => "123"
    assert_response :success
    assert_template :details
  end
end
