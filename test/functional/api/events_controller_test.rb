require 'test_helper'

class Api::EventsControllerTest < ActionController::TestCase

  setup do
    @coordinates = Rails.application.config.app.default_coordinates
  end

  context 'index' do

    setup do
      EventSet.expects(:upcoming_near).with(@coordinates).returns([event])
      get :index, :format => :json, :lat => @coordinates.first, :lng => @coordinates.last
    end

    should 'be successful' do
      assert_response :success
    end

    context 'parsed response' do

      setup do
        @result = MultiJson.decode(response.body)
      end

      should 'contain an array of events' do
        assert_kind_of Array, @result['events']
      end

      should 'have links for each event' do
        assert_equal api_event_url(:id => 123), @result['events'].first['links']['event']
      end

    end

  end

  def event
    event = Event.new do |e|
      e.id        = 123
      e.name      = '1st Annual Busker Festival'
      e.address   = '2578 Binghamton Drive'
      e.city      = 'Atlanta'
      e.latitude  = 33.7489954
      e.longitude = -84.3879824
    end
  end

end