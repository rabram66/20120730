require 'test_helper'

class NewstuffsControllerTest < ActionController::TestCase
  setup do
    @newstuff = newstuffs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:newstuffs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create newstuff" do
    assert_difference('Newstuff.count') do
      post :create, :newstuff => @newstuff.attributes
    end

    assert_redirected_to newstuff_path(assigns(:newstuff))
  end

  test "should show newstuff" do
    get :show, :id => @newstuff.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @newstuff.to_param
    assert_response :success
  end

  test "should update newstuff" do
    put :update, :id => @newstuff.to_param, :newstuff => @newstuff.attributes
    assert_redirected_to newstuff_path(assigns(:newstuff))
  end

  test "should destroy newstuff" do
    assert_difference('Newstuff.count', -1) do
      delete :destroy, :id => @newstuff.to_param
    end

    assert_redirected_to newstuffs_path
  end
end
