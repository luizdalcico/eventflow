require "test_helper"

class CortejoFlowTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(
      title: "Casamento Teste",
      event_type: "wedding",
      main_date: Date.current + 1.month,
      estimated_guests: 100
    )
  end

  test "cortejo page renders for a wedding" do
    get event_cortejo_path(@event)
    assert_response :success
    assert_select "h1", /Cortejo/
  end

  test "creates a procession step and assigns the next position" do
    assert_difference -> { @event.procession_steps.count }, 1 do
      post event_procession_steps_path(@event), as: :turbo_stream, params: {
        procession_step: { description: "Entrada da noiva", kind: "entrada" }
      }
    end
    step = @event.procession_steps.last
    assert_equal "Entrada da noiva", step.description
    assert_equal "entrada", step.kind
    assert_equal 1, step.position
  end

  test "updating a procession step persists the new values" do
    step = @event.procession_steps.create!(description: "Leitura", position: 1)
    patch event_procession_step_path(@event, step), params: {
      procession_step: { description: "Salmo responsorial", kind: "salmo" }
    }
    step.reload
    assert_equal "Salmo responsorial", step.description
    assert_equal "salmo", step.kind
  end

  test "destroying a procession step removes it" do
    step = @event.procession_steps.create!(description: "Saída", position: 1)
    assert_difference -> { @event.procession_steps.count }, -1 do
      delete event_procession_step_path(@event, step), as: :turbo_stream
    end
  end

  test "creates a family member and assigns the next position" do
    assert_difference -> { @event.family_members.count }, 1 do
      post event_family_members_path(@event), as: :turbo_stream, params: {
        family_member: { name: "Dona Maria", role: "mae_noiva", notes: "Cadeira reservada" }
      }
    end
    member = @event.family_members.last
    assert_equal "Dona Maria", member.name
    assert_equal "mae_noiva", member.role
    assert_equal "Cadeira reservada", member.notes
    assert_equal 1, member.position
  end

  test "updating a family member persists the new values" do
    member = @event.family_members.create!(name: "Maria", position: 1)
    patch event_family_member_path(@event, member), params: {
      family_member: { name: "Maria Silva", role: "testemunha" }
    }
    member.reload
    assert_equal "Maria Silva", member.name
    assert_equal "testemunha", member.role
  end

  test "destroying a family member removes it" do
    member = @event.family_members.create!(name: "Maria", position: 1)
    assert_difference -> { @event.family_members.count }, -1 do
      delete event_family_member_path(@event, member), as: :turbo_stream
    end
  end
end
