require "test_helper"

class EventProvidersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get event_providers_index_url
    assert_response :success
  end

  test "should get show" do
    get event_providers_show_url
    assert_response :success
  end

  test "should get new" do
    get event_providers_new_url
    assert_response :success
  end

  test "should get create" do
    get event_providers_create_url
    assert_response :success
  end

  test "should get edit" do
    get event_providers_edit_url
    assert_response :success
  end

  test "should get update" do
    get event_providers_update_url
    assert_response :success
  end

  test "should get destroy" do
    get event_providers_destroy_url
    assert_response :success
  end

  test "should get update_details" do
    get event_providers_update_details_url
    assert_response :success
  end
end
