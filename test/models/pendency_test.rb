require "test_helper"

class PendencyTest < ActiveSupport::TestCase
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
  end

  test "requires a description" do
    pendency = @event.pendencies.new(description: nil)
    assert_not pendency.valid?
    assert_includes pendency.errors[:description], I18n.t("errors.messages.blank")
  end

  test "defaults status to pendente" do
    pendency = @event.pendencies.create!(description: "Enviar contrato")
    assert_equal "pendente", pendency.status
  end

  test "rejects a status outside the allowed set" do
    pendency = @event.pendencies.new(description: "X", status: "invalido")
    assert_not pendency.valid?
    assert_includes pendency.errors[:status], I18n.t("errors.messages.inclusion")
  end

  test "meeting and event_provider are optional" do
    pendency = @event.pendencies.new(description: "Item geral")
    assert pendency.valid?
  end

  test "pending excludes concluded items" do
    open_item = @event.pendencies.create!(description: "Aberta", status: "pendente")
    progressing = @event.pendencies.create!(description: "Andando", status: "em_andamento")
    @event.pendencies.create!(description: "Feita", status: "concluida")

    assert_equal [ open_item, progressing ].sort_by(&:id), @event.pendencies.pending.order(:id).to_a
  end

  test "ordered sorts by status then due date" do
    later = @event.pendencies.create!(description: "B", status: "concluida", due_date: Date.current + 10)
    sooner = @event.pendencies.create!(description: "A", status: "concluida", due_date: Date.current + 1)
    pending = @event.pendencies.create!(description: "C", status: "pendente", due_date: Date.current + 5)

    # status asc: "concluida" < "em_andamento" < "pendente"; within status, due_date asc.
    assert_equal [ sooner, later, pending ], @event.pendencies.ordered.to_a
  end
end
