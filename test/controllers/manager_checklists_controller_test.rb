require "test_helper"

class ManagerChecklistsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manager_checklists_index_url
    assert_response :success
  end

  test "should get show" do
    get manager_checklists_show_url
    assert_response :success
  end

  test "should get new" do
    get manager_checklists_new_url
    assert_response :success
  end

  test "should get create" do
    get manager_checklists_create_url
    assert_response :success
  end

  test "should get edit" do
    get manager_checklists_edit_url
    assert_response :success
  end

  test "should get update" do
    get manager_checklists_update_url
    assert_response :success
  end

  test "should get destroy" do
    get manager_checklists_destroy_url
    assert_response :success
  end

  test "should get toggle_completed" do
    get manager_checklists_toggle_completed_url
    assert_response :success
  end
end
