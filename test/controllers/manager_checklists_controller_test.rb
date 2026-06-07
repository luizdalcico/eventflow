require "test_helper"

class ManagerChecklistsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
  end

  test "index renders the checklist page" do
    @event.manager_checklists.create!(task: "Reservar buffet")

    get event_manager_checklists_url(@event)
    assert_response :success
    assert_select "#checklist_items"
    assert_select "h1", text: "Checklist"
  end

  test "index shows the empty state when there are no tasks" do
    get event_manager_checklists_url(@event)
    assert_response :success
    assert_select "#checklist_empty"
  end

  test "create adds a task to the event" do
    assert_difference -> { @event.manager_checklists.count }, 1 do
      post event_manager_checklists_url(@event), as: :turbo_stream,
           params: { manager_checklist: { task: "Confirmar fornecedores" } }
    end
    assert_response :success
    assert_equal "Confirmar fornecedores", @event.manager_checklists.last.task
  end

  test "create with a blank task does not persist" do
    assert_no_difference -> { @event.manager_checklists.count } do
      post event_manager_checklists_url(@event), as: :turbo_stream,
           params: { manager_checklist: { task: "" } }
    end
    assert_response :success
  end

  test "update persists the new values" do
    item = @event.manager_checklists.create!(task: "Tarefa antiga")

    patch event_manager_checklist_url(@event, item),
          params: { manager_checklist: { task: "Tarefa nova", completed: true } }
    assert_response :no_content

    item.reload
    assert_equal "Tarefa nova", item.task
    assert item.completed?
  end

  test "destroy removes the task" do
    item = @event.manager_checklists.create!(task: "Remover esta")

    assert_difference -> { @event.manager_checklists.count }, -1 do
      delete event_manager_checklist_url(@event, item), as: :turbo_stream
    end
    assert_response :success
  end
end
