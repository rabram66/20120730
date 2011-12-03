require 'test_helper'

class LocationsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user1)
    @location = locations(:one)
  end

  test "should get index" do
    Place.expects(:find_by_geocode).with([33.7489954, -84.3879824],LocationCategory::EatDrink.types).returns([])
    get :index
    assert_not_nil assigns(:locations)
    assert_response :success
    assert_template :index
  end

  test "should get details for location" do
    Tweet.expects(:latest).with(@location.twitter_name).returns(nil)
    Tweet.expects(:search).with(@location.twitter_name,40).returns([])
    get :details, :reference => @location.reference
    assert_response :success
    assert_template :details
  end
  
  test "should get details for place" do
    place = Place.new
    place.vicinity = '2578 Binghamton Drive, Atlanta'
    place.geo_code = [33.7489954, -84.3879824]
    Place.expects(:find_by_reference).with('123').returns(place)
    get :details, :reference => "123"
    assert_response :success
    assert_template :details
  end
  
  test "should get new" do
    get :new
    assert_response :success
    assert_template :new
  end
  
  test "should create location" do
    @location.reference = nil
    Location.any_instance.expects(:geocode).once
    # Place.add
    stub_request(:post, "https://maps.googleapis.com/maps/api/place/add/json?key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc&sensor=false").
      with(:body => "{\"location\":{\"lat\":33.7489954,\"lng\":-84.3879824},\"accuracy\":50,\"name\":\"Waffle House\",\"types\":[\"restaurant\"],\"language\":\"en-US\"}", 
           :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'127', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "{\"status\":\"OK\",\"reference\":123}", :headers => {})
  
    assert_difference('Location.count') do
      post :create, :location => @location.attributes
    end
    assert_redirected_to location_path(assigns(:location))
  end
  
  test "should show location" do
    Tweet.expects(:latest).with(@location.twitter_name,10).returns([])
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
    # Place.delete
    stub_request(:post, "https://maps.googleapis.com/maps/api/place/delete/json?key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc&sensor=false").
      with(:body => "{\"reference\":\"CkQxAAAArz9vJIHLTxCNB6kt_95L0uVcnXK9YzeKuiAp2cw57zt6HSHKVYOvE4WjBvDFRP75KVACvPg05ilfQvGv6IdnkhIQK_T0BsGxeAOfZYfivT9FQRoUjq-MvFBFqdhhg_gqMQxInAkin2\"}", 
           :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'162', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "{\"status\":\"OK\"}", :headers => {})

    assert_difference('Location.count', -1) do
      delete :destroy, :id => @location.to_param
    end
    assert_redirected_to locations_path
  end
  
  test 'should load deals' do
    Deal.expects(:find_by_geocode).with([33.7489954, -84.3879824]).returns([Deal.new(:title => 'Test deal', :url => 'http://www.example.com')])
    get :load_deals
    assert_response :success
    assert_template :deals
    assert_select 'div.deal_link'
  end

end
