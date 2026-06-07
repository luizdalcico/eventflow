require "test_helper"

class OwnerChecklistsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
  end

  test "index renders the checklist page" do
    @event.owner_checklists.create!(task: "Escolher convites")

    get event_owner_checklists_url(@event)
    assert_response :success
    assert_select "#checklist_items"
    assert_select "h1", text: "Checklist dos responsáveis"
  end

  test "index shows the empty state when there are no tasks" do
    get event_owner_checklists_url(@event)
    assert_response :success
    assert_select "#checklist_empty"
  end

  test "create adds a task to the event" do
    assert_difference -> { @event.owner_checklists.count }, 1 do
      post event_owner_checklists_url(@event), as: :turbo_stream,
           params: { owner_checklist: { task: "Provar o bolo" } }
    end
    assert_response :success
    assert_equal "Provar o bolo", @event.owner_checklists.last.task
  end

  test "create with a blank task does not persist" do
    assert_no_difference -> { @event.owner_checklists.count } do
      post event_owner_checklists_url(@event), as: :turbo_stream,
           params: { owner_checklist: { task: "" } }
    end
    assert_response :success
  end

  test "update persists the new values" do
    item = @event.owner_checklists.create!(task: "Tarefa antiga")

    patch event_owner_checklist_url(@event, item),
          params: { owner_checklist: { task: "Tarefa nova", completed: true } }
    assert_response :no_content

    item.reload
    assert_equal "Tarefa nova", item.task
    assert item.completed?
  end

  test "destroy removes the task" do
    item = @event.owner_checklists.create!(task: "Remover esta")

    assert_difference -> { @event.owner_checklists.count }, -1 do
      delete event_owner_checklist_url(@event, item), as: :turbo_stream
    end
    assert_response :success
  end
end
