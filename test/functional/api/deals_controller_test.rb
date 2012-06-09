require 'test_helper'

class Api::DealsControllerTest < ActionController::TestCase

  setup do
    @coordinates = Rails.application.config.app.default_coordinates
  end

  context 'index' do

    setup do
      DealSet.expects(:near).with(@coordinates).returns([deal])
      get :index, :format => :json, :lat => @coordinates.first, :lng => @coordinates.last
      @result = MultiJson.decode(response.body)
    end

    should 'be successful' do
      assert_response :success
    end

    context 'parsed response' do
      should 'contain an array of deals' do
        assert_kind_of Array, @result['deals']
      end
      should 'have empty strings for nils' do
        assert_equal '', @result['deals'].first['name']
      end
    end

  end
  
  def deal
    Deal.new.tap do |d|
      d.title       = 'Bozos'
      d.description = 'test'
    end
  end

end