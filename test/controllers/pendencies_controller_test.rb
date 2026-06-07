require "test_helper"

class PendenciesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
    @meeting = @event.meetings.create!(date: Date.current)
    provider = Provider.create!(provider_type: "photographer", name: "Foto Top",
                                contact_name: "Ana", phone_number: "85999990000",
                                document: "12345678000190")
    @event_provider = @event.event_providers.create!(provider: provider, status: "contratado",
                                                     professionals_count: 1, value: 1000)
  end

  test "create a general pendency persists the values" do
    assert_difference -> { @event.pendencies.count }, 1 do
      post event_pendencies_url(@event), as: :turbo_stream,
           params: { pendency: { description: "Item geral", assignee: "Marina",
                                 status: "em_andamento", due_date: Date.current + 3 } }
    end
    assert_response :success
    pendency = @event.pendencies.last
    assert_equal "Item geral", pendency.description
    assert_equal "Marina", pendency.assignee
    assert_equal "em_andamento", pendency.status
    assert_nil pendency.meeting_id
    assert_nil pendency.event_provider_id
  end

  test "create a pendency linked to a meeting and provider" do
    assert_difference -> { @event.pendencies.count }, 1 do
      post event_pendencies_url(@event), as: :turbo_stream,
           params: { pendency: { description: "Confirmar pacote", status: "pendente",
                                 meeting_id: @meeting.id, event_provider_id: @event_provider.id } }
    end
    assert_response :success
    pendency = @event.pendencies.last
    assert_equal @meeting.id, pendency.meeting_id
    assert_equal @event_provider.id, pendency.event_provider_id
  end

  test "create with a blank description does not persist" do
    assert_no_difference -> { @event.pendencies.count } do
      post event_pendencies_url(@event), as: :turbo_stream,
           params: { pendency: { description: "" } }
    end
    assert_response :success
  end

  test "update persists the new values" do
    pendency = @event.pendencies.create!(description: "Antiga", status: "pendente")

    patch event_pendency_url(@event, pendency),
          params: { pendency: { description: "Nova", status: "concluida" } }
    assert_response :no_content

    pendency.reload
    assert_equal "Nova", pendency.description
    assert_equal "concluida", pendency.status
  end

  test "destroy removes the pendency" do
    pendency = @event.pendencies.create!(description: "Remover")

    assert_difference -> { @event.pendencies.count }, -1 do
      delete event_pendency_url(@event, pendency), as: :turbo_stream
    end
    assert_response :success
  end

  test "pendencies are scoped to their event" do
    other = Event.create!(title: "Outro", event_type: "wedding",
                          main_date: Date.current + 2.months, estimated_guests: 50)
    pendency = other.pendencies.create!(description: "De outro evento")

    delete event_pendency_url(@event, pendency), as: :turbo_stream
    assert_response :not_found
  end
end
