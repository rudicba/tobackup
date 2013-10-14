require 'test_helper'

class TesthostsControllerTest < ActionController::TestCase
  setup do
    @testhost = testhosts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:testhosts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create testhost" do
    assert_difference('Testhost.count') do
      post :create, testhost: { ip: @testhost.ip, name: @testhost.name, status: @testhost.status }
    end

    assert_redirected_to testhost_path(assigns(:testhost))
  end

  test "should show testhost" do
    get :show, id: @testhost
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @testhost
    assert_response :success
  end

  test "should update testhost" do
    patch :update, id: @testhost, testhost: { ip: @testhost.ip, name: @testhost.name, status: @testhost.status }
    assert_redirected_to testhost_path(assigns(:testhost))
  end

  test "should destroy testhost" do
    assert_difference('Testhost.count', -1) do
      delete :destroy, id: @testhost
    end

    assert_redirected_to testhosts_path
  end
end
