require 'test_helper'

class PlacesControllerTest < ActionController::TestCase

  setup do
    @location = locations(:one)
  end

  context 'GET index' do
    should "succeed" do
      Geocoder.expects(:coordinates).returns([0.0,0.0])
      Place.expects(:find_by_geocode).with([0.0,0.0],LocationCategory::EatDrink.types).returns([])
      # Place.expects(:find_by_geocode).with([33.7489954, -84.3879824],LocationCategory::EatDrink.types).returns([])
      Event.expects(:upcoming_near).returns([])
      EventBrite.expects(:geosearch).returns([])
      DealSet.expects(:find_by_geocode).with([0.0,0.0]).returns(DealSet.new([]))
      # Deal.expects(:find_by_geocode).with([33.7489954, -84.3879824]).returns(DealSet.new([]))
    
      get :index, :search => 'Atlanta, GA'
      assert_not_nil assigns(:locations)
      assert_response :success
      assert_template :index
    end
  end

  context 'GET details for location' do
    should "succeed" do
      Tweet.expects(:user_status).with(@location.twitter_name).returns(nil)
      Tweet.expects(:geosearch).with("@#{@location.twitter_name}",@location.coordinates, 5, 40).returns([])
      Tweet.expects(:geosearch).with("\"#{@location.name}\"",@location.coordinates, 5, 40).returns([])
      Tweet.expects(:non_geosearch).with("@#{@location.twitter_name}", 40).returns([])
      Tweet.expects(:non_geosearch).with("\"#{@location.name}\"", 40).returns([])
      get :details, :reference => @location.slug
      assert_response :success
      assert_template :details
    end
  end

  # stub_request(:get, "http://search.twitter.com/search.json?geocode=33.7489954,-84.3879824,5mi&include_entities=1&page=1&q=@wafflehouse&rpp=40").
  #           with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
  #           to_return(:status => 200, :body => "", :headers => {})
  
  context 'GET details for Google place' do
    should "redirect to slug on valid reference" do
      place           = Place.new
      place.name      = 'Bozos'
      place.address   = '2578 Binghamton Drive'
      place.city      = 'Atlanta'
      # place.latitude  = 33.7489954
      # place.longitude = -84.3879824
      Place.expects(:find_by_reference).with('CqHDHYDY63636').returns(place)
      # Tweet.expects(:geosearch).with("\"#{place.name}\"",place.coordinates,5,40).returns([])
      get :details, :reference => "CqHDHYDY63636"
      assert_response :redirect
      # assert_template :details
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
