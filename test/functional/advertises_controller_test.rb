require 'test_helper'

class AdvertisesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user1)
    @advertise = advertises(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:advertises)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create advertise" do
    assert_difference('Advertise.count') do
      post :create, :advertise => @advertise.attributes
    end

    assert_redirected_to advertise_path(assigns(:advertise))
  end

  test "should show advertise" do
    get :show, :id => @advertise.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @advertise.to_param
    assert_response :success
  end

  test "should update advertise" do
    put :update, :id => @advertise.to_param, :advertise => @advertise.attributes
    assert_redirected_to advertise_path(assigns(:advertise))
  end

  test "should destroy advertise" do
    stub_request(:any, %r{^http://s3\.amazonaws\.com/nearbythisdevelopment/photos/980190962/(original|medium|thumb)/MyString$}).
      to_return(:status => 200, :body => "", :headers => {})
    assert_difference('Advertise.count', -1) do
      delete :destroy, :id => @advertise.to_param
    end

    assert_redirected_to advertises_path
  end
end
