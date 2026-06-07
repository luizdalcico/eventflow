require "test_helper"

class DateTemplateTest < ActiveSupport::TestCase
  def setup
    @main_date = Date.new(2026, 12, 1)
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: @main_date, estimated_guests: 100)
  end

  test "items_for returns the catalog for a known event type" do
    items = DateTemplate.items_for("wedding")

    assert_equal 10, items.size
    assert items.all? { |item| item[:description].present? }
  end

  test "items_for returns an empty array for an unknown event type" do
    assert_equal [], DateTemplate.items_for("bodas")
  end

  test "available_for? reflects whether a template exists" do
    assert DateTemplate.available_for?("wedding")
    assert_not DateTemplate.available_for?("bodas")
  end

  test "apply resolves relative offsets against the main date" do
    DateTemplate.apply(@event)

    convites = @event.event_dates.find_by!(description: "Entrega/envio dos convites")
    assert_equal @main_date - 45.days, convites.date

    lista = @event.event_dates.find_by!(description: "Prazo final da lista de convidados")
    assert_equal @main_date - 10.days, lista.date
  end

  test "apply seeds contract items with the main date as placeholder" do
    DateTemplate.apply(@event)

    pagamento = @event.event_dates.find_by!(description: "Pagamento final (conforme contrato)")
    assert_equal @main_date, pagamento.date
  end

  test "apply persists every catalog item for the event type" do
    assert_difference -> { @event.event_dates.count }, DateTemplate.items_for("wedding").size do
      DateTemplate.apply(@event)
    end
  end

  test "apply returns the created event dates" do
    created = DateTemplate.apply(@event)

    assert_equal DateTemplate.items_for("wedding").size, created.size
    assert created.all?(&:persisted?)
  end

  test "apply is idempotent on description so re-applying adds nothing" do
    DateTemplate.apply(@event)

    assert_no_difference -> { @event.event_dates.count } do
      assert_equal [], DateTemplate.apply(@event)
    end
  end

  test "apply only adds the missing descriptions when some already exist" do
    @event.event_dates.create!(description: "Curso de noivos", date: @main_date)

    expected = DateTemplate.items_for("wedding").size - 1
    assert_difference -> { @event.event_dates.count }, expected do
      DateTemplate.apply(@event)
    end
  end

  test "apply does nothing for an event type without a template" do
    event = Event.create!(title: "Bodas", event_type: "bodas",
                          main_date: @main_date, estimated_guests: 30)

    assert_no_difference -> { event.event_dates.count } do
      assert_equal [], DateTemplate.apply(event)
    end
  end

  test "apply returns an empty array and seeds nothing when the main date is blank" do
    @event.main_date = nil

    assert_no_difference -> { @event.event_dates.count } do
      assert_equal [], DateTemplate.apply(@event)
    end
  end
end
