require "test_helper"

class DateTemplateTest < ActiveSupport::TestCase
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.new(2026, 12, 1), estimated_guests: 100)
  end

  test "items_for returns the catalog descriptions for a known event type" do
    items = DateTemplate.items_for("wedding")

    assert_equal 10, items.size
    assert items.all? { |description| description.is_a?(String) && description.present? }
  end

  test "items_for returns an empty array for an unknown event type" do
    assert_equal [], DateTemplate.items_for("bodas")
  end

  test "available_for? reflects whether a template exists" do
    assert DateTemplate.available_for?("wedding")
    assert_not DateTemplate.available_for?("bodas")
  end

  test "apply seeds every milestone without a date" do
    DateTemplate.apply(@event)

    seeded = @event.event_dates
    assert_equal DateTemplate.items_for("wedding").size, seeded.count
    assert seeded.all? { |event_date| event_date.date.nil? }
    assert @event.event_dates.exists?(description: "Entrega/envio dos convites")
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
    @event.event_dates.create!(description: "Curso de noivos")

    expected = DateTemplate.items_for("wedding").size - 1
    assert_difference -> { @event.event_dates.count }, expected do
      DateTemplate.apply(@event)
    end
  end

  test "apply does nothing for an event type without a template" do
    event = Event.create!(title: "Bodas", event_type: "bodas",
                          main_date: Date.new(2026, 12, 1), estimated_guests: 30)

    assert_no_difference -> { event.event_dates.count } do
      assert_equal [], DateTemplate.apply(event)
    end
  end
end
