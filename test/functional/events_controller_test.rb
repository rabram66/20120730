require 'test_helper'

class EventsControllerTest < ActionController::TestCase

  context 'as a promoter' do
    
    setup do
      sign_in users(:promoter)
    end

    should "get index and only show owned events" do
      get :index
      assert_response :success
      assert_not_nil assigns(:events)
      assigns(:events).each {|event| assert_equal users(:promoter), event.user}
    end

    context 'with an event that is not mine' do
      setup do
        @event = events(:anonymous)
      end

      [:edit, :destroy, :update].each do |action|
        should "deny access to #{action}" do
          get action, id: @event.id
          assert_redirected_to root_url
          assert_equal "Access Denied", flash.notice
        end
      end
    end

    context 'with an event that is mine' do
      setup do
        @event = events(:promoted)
        Event.any_instance.stubs(:tweets).returns([])
      end

      [:edit].each do |action|
        should "allow access to #{action}" do
          get action, id: @event.id
          assert_response :success
        end
      end

      should "allow access to destroy" do
        delete :destroy, id: @event.id
        assert_redirected_to events_path
      end

      should "allow access to update" do
        put :update, id: @event.id
        assert_redirected_to event_path(assigns(:event))
      end

    end

  end

  context 'as an admin user' do

    setup do
      sign_in users(:admin)
      @event = events(:anonymous)
      Event.any_instance.stubs(:tweets).returns([])
    end

    should "get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:events)
    end

    should "get new" do
      get :new
      assert_response :success
    end

    should "create event" do
      Event.any_instance.expects(:geocode).once
      assert_difference('Event.count') do
        post :create, event: @event.attributes
      end

      assert_redirected_to event_path(assigns(:event))
    end

    should "get edit" do
      get :edit, id: @event.to_param
      assert_response :success
    end

    should "update event" do
      put :update, id: @event.to_param, event: @event.attributes
      assert_redirected_to event_path(assigns(:event))
    end

    should "destroy event" do
      assert_difference('Event.count', -1) do
        delete :destroy, id: @event.to_param
      end

      assert_redirected_to events_path
    end
  
  end
  
end
