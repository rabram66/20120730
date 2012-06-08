require 'test_helper'

class PlacesControllerTest < ActionController::TestCase

  setup do
    @location = locations(:one)
  end

  context 'GET index' do
    should "succeed" do
      expectations_for_index
      get :index, :search => 'Atlanta, GA'
      assert_not_nil assigns(:locations)
      assert_response :success
      assert_template :index
    end
  end

  def expectations_for_index
    Geocoder.expects(:coordinates).returns([0.0,0.0])
    Place.expects(:find_by_geocode).returns([])
    EventSet.expects(:upcoming_near).returns([])
    DealSet.expects(:near).with([0.0,0.0]).returns(DealSet.new([]))
  end

  context 'GET details for location' do
    should "succeed" do
      Geocoder.expects(:coordinates).returns([0.0,0.0])
      Place.expects(:find_by_geocode).returns([])
      # EventBriteApi.expects(:geosearch).returns([])
      DealSet.expects(:near).returns(DealSet.new([]))
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

  context 'GET details for Google place' do
    should "redirect to slug on valid reference" do
      Geocoder.expects(:coordinates).returns([0.0,0.0])
      Place.expects(:find_by_geocode).returns([])
      # EventBriteApi.expects(:geosearch).returns([])
      DealSet.expects(:near).returns(DealSet.new([]))

      place           = Place.new
      place.name      = 'Bozos'
      place.address   = '2578 Binghamton Drive'
      place.city      = 'Atlanta'
      place.reference = 'CqHDHYDY63636'

      Place.expects(:find_by_reference).with('CqHDHYDY63636').returns(place)
      get :details, :reference => "CqHDHYDY63636"
      assert_response :redirect
    end
    
  end
  
end
