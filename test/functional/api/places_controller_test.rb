require 'test_helper'

class Api::PlacesControllerTest < ActionController::TestCase

  setup do
    @coordinates = Rails.application.config.app.default_coordinates
  end

  context 'index' do
    should 'be successful' do
      PlaceLoader.expects(:near).with(@coordinates).returns([place])
      get :index, :format => :json, :lat => @coordinates.first, :lng => @coordinates.last
      assert_response :success
    end
    # context 'parsed response' do
    #   setup do
    #     get :index
    #     @places = MultiJson.decode(response.body)
    #   end
    #   should 'contain an array of places' do
    #     get :index
    #     res = MultiJson.decode(response.body)
    #     assert_equal api_places_url, res['links']['places']
    #   end
    # end
  end

  def place
    place           = Place.new
    place.name      = 'Bozos'
    place.address   = '2578 Binghamton Drive'
    place.city      = 'Atlanta'
    place.latitude  = 33.7489954
    place.longitude = -84.3879824
    place.reference = '12345'
    place.categories = [LocationCategory::EatDrink]
    place
  end

end