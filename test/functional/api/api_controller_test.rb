require 'test_helper'

class Api::ApiControllerTest < ActionController::TestCase

  context 'index' do
    should 'be successful' do
      get :index, :format => :json
      assert_response :success
    end
    should 'contain JSON representation of links' do
      get :index, :format => :json
      res = MultiJson.decode(response.body)
      assert_equal api_places_url, res['links']['places']
    end
  end

end