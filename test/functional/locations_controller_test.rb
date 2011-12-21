require 'test_helper'

class LocationsControllerTest < ActionController::TestCase

  context 'as an unauthenticated user' do
    [:index, :new, :edit, :show, :create, :destroy].each do |action|
      should "be denied access to #{action}" do
        get action, :id => 1
        assert_redirected_to root_url
      end
    end
  end

  context 'as an admin user' do
      
    setup do
      sign_in users(:admin)
      @location = locations(:one)
    end
  
    should "get new" do
      get :new
      assert_response :success
      assert_template :new
    end
  
    should "create location" do
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
  
    should "show location" do
      Tweet.expects(:user_status).twice.with(@location.twitter_name).returns(Tweet.new(:text => 'foo'))
      get :show, :id => @location.to_param
      assert_response :success
      assert_template :show
    end
  
    should "get edit" do
      get :edit, :id => @location.to_param
      assert_response :success
      assert_template :edit
    end
  
    should "update location" do
      put :update, :id => @location.to_param, :location => @location.attributes
      assert_redirected_to location_path(assigns(:location))
    end

    should "destroy location" do
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

  end
  
end
