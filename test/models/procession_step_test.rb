require "test_helper"

class ProcessionStepTest < ActiveSupport::TestCase
  def setup
    @event = Event.create!(
      title: "Casamento Teste",
      event_type: "wedding",
      main_date: Date.current + 1.month,
      estimated_guests: 100
    )
  end

  test "is valid with a description" do
    step = @event.procession_steps.new(description: "Entrada da noiva")
    assert step.valid?
  end

  test "requires a description" do
    step = @event.procession_steps.new(description: "")
    assert_not step.valid?
    assert_includes step.errors.attribute_names, :description
  end

  test "accepts a blank kind" do
    step = @event.procession_steps.new(description: "Saída", kind: "")
    assert step.valid?
  end

  test "rejects a kind outside the allowed list" do
    step = @event.procession_steps.new(description: "Saída", kind: "invalido")
    assert_not step.valid?
    assert_includes step.errors.attribute_names, :kind
  end

  test "ordered scope sorts by persisted position" do
    second = @event.procession_steps.create!(description: "Segundo", position: 2)
    first = @event.procession_steps.create!(description: "Primeiro", position: 1)
    assert_equal [ first.id, second.id ], @event.procession_steps.ordered.pluck(:id)
  end
end
