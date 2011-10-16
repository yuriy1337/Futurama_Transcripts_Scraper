require 'test_helper'

class ExchangesControllerTest < ActionController::TestCase
  setup do
    @exchange = exchanges(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:exchanges)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create exchange" do
    assert_difference('Exchange.count') do
      post :create, :exchange => @exchange.attributes
    end

    assert_redirected_to exchange_path(assigns(:exchange))
  end

  test "should show exchange" do
    get :show, :id => @exchange.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @exchange.to_param
    assert_response :success
  end

  test "should update exchange" do
    put :update, :id => @exchange.to_param, :exchange => @exchange.attributes
    assert_redirected_to exchange_path(assigns(:exchange))
  end

  test "should destroy exchange" do
    assert_difference('Exchange.count', -1) do
      delete :destroy, :id => @exchange.to_param
    end

    assert_redirected_to exchanges_path
  end
end
