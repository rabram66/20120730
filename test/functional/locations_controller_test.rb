require 'test_helper'

class LocationsControllerTest < ActionController::TestCase

  setup do
    @location = locations(:one)
  end

  context 'an unauthenticated user' do
    [:index, :new, :edit, :show, :create, :destroy].each do |action|
      should "be denied access to #{action}" do
        get action, id: @location.id
        assert_redirected_to root_url
        assert_equal 'Access Denied', flash.notice
      end
    end
  end

  context 'as an admin user' do
      
    setup do
      sign_in users(:admin)
    end
  
    should "get new" do
      get :new
      assert_response :success
      assert_template :new
    end
  
    should "create location" do
      @location.reference = nil
      @location.name = 'FalaflHouse'
      Location.any_instance.expects(:geocode).twice

      # Place.add
      stub_request(:post, "https://maps.googleapis.com/maps/api/place/add/json?key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc&sensor=false").
        with(:body => "{\"location\":{\"lat\":33.7489954,\"lng\":-84.3879824},\"accuracy\":50,\"name\":\"#{@location.name}\",\"types\":[\"restaurant\"],\"language\":\"en-US\"}").
        to_return(:status => 200, :body => "{\"status\":\"OK\",\"reference\":123}", :headers => {})

      #Place.delete
      stub_request(:post, "https://maps.googleapis.com/maps/api/place/delete/json?key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc&sensor=false").
        with(:body => "{\"reference\":123}").
        to_return(:status => 200, :body => "{\"status\":\"OK\",\"reference\":123}", :headers => {})

        
      Twitter.expects(:user).with(@location.twitter_name).returns(stub(:profile_image_url=>'http://foo.com',:description=>'foo'))

      # Update profile image and description from twitter
      # stub_request(:get, "https://api.twitter.com/1/users/show.json?screen_name=wafflehouse").
      #   to_return(:status => 200, :body => "", :headers => {})
  
      assert_difference('Location.count') do
        post :create, :location => @location.attributes
      end
      assert_redirected_to location_details_path(:reference => assigns(:location).reference)
    end
  
    should "show location" do
      get :show, :id => @location.to_param
      assert_redirected_to location_details_path(:reference => assigns(:location).reference)
    end
  
    should "get edit" do
      get :edit, :id => @location.to_param
      assert_response :success
      assert_template :edit
    end
  
    should "update location" do
      put :update, :id => @location.to_param, :location => @location.attributes
      assert_redirected_to locations_path
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
