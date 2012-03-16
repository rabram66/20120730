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
    context 'parsed response' do
      setup do
        PlaceLoader.expects(:near).with(@coordinates).returns([place])
        get :index, :format => :json, :lat => @coordinates.first, :lng => @coordinates.last
        @result = MultiJson.decode(response.body)
      end
      should 'contain an array of places' do
        assert_kind_of Array, @result['places']
      end
    end
  end

  def place
    Place.new.tap do |p|
      p.name      = 'Bozos'
      p.address   = '2578 Binghamton Drive'
      p.city      = 'Atlanta'
      p.latitude  = 33.7489954
      p.longitude = -84.3879824
      p.reference = '12345'
      p.categories = [LocationCategory::EatDrink]
    end
  end

end