require 'test_helper'

class IphoneControllerTest < ActionController::TestCase
  
  DEFAULT_COORDINATES = [33.7489954, -84.3879824]
  
  def assert_index_body
    assert_select "Result" do
      assert_select "BusinessList" do
        assert_select "Business", 2
        assert_select "Business" do
          assert_select "name"
          assert_select "location"
          assert_select "distance"
          assert_select "reference"
        end
      end
      assert_select "deal_size", '1'
      assert_select "event", '0'
      assert_select "lat",'33.7489954'
      assert_select "lng",'-84.3879824'
    end
  end

  test "should get index with no params" do
    Place.expects(:find_by_geocode).with(DEFAULT_COORDINATES, LocationCategory::EatDrink.types).returns([])
    Deal.expects(:find_by_geocode).with(DEFAULT_COORDINATES).returns([:foo])
    get :index, :format => :xml
    assert_response :success
    assert_index_body
  end
  
  test "should get index with lat and lng" do
    Place.expects(:find_by_geocode).with([33.928, -84.282], LocationCategory::EatDrink.types).returns([])
    Deal.expects(:find_by_geocode).with([33.928, -84.282]).returns([:foo])
    get :index, :lat => '33.928', :lng => '-84.282', :format => :xml
    assert_response :success
  end

  test "should get index with address" do
    Geocoder.expects(:coordinates).with('123 Mockingbird Lane, Atlanta GA').returns([33.928, -84.282])
    Place.expects(:find_by_geocode).with([33.928, -84.282],LocationCategory::EatDrink.types).returns([])
    Deal.expects(:find_by_geocode).with([33.928, -84.282]).returns([:foo])
    get :index, :address => '123 Mockingbird Lane, Atlanta GA', :format => :xml
    assert_response :success
  end

  def assert_deals_body
    assert_select "Result" do
      assert_select "Deals" do
        assert_select "Deal", 2
        assert_select "Deal" do
          assert_select "title"
          assert_select "link"
        end
      end
    end
  end

  test "should get deals" do
    Deal.expects(:find_by_geocode).with(DEFAULT_COORDINATES).returns([
      Deal.new(:title => 'Some Deal', :link => 'http://www.example.com/deal'),
      Deal.new(:title => 'Some Other Deal', :link => 'http://www.example.com/other'),
    ])
    get :deals, :format => :xml
    assert_response :success
    assert_deals_body
  end


end
