require "test_helper"

class GuestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get guests_index_url
    assert_response :success
  end

  test "should get show" do
    get guests_show_url
    assert_response :success
  end

  test "should get new" do
    get guests_new_url
    assert_response :success
  end

  test "should get create" do
    get guests_create_url
    assert_response :success
  end

  test "should get edit" do
    get guests_edit_url
    assert_response :success
  end

  test "should get update" do
    get guests_update_url
    assert_response :success
  end

  test "should get destroy" do
    get guests_destroy_url
    assert_response :success
  end

  test "should get toggle_godparent" do
    get guests_toggle_godparent_url
    assert_response :success
  end
end
