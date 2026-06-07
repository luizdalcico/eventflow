require "test_helper"

class EventDateTest < ActiveSupport::TestCase
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.new(2026, 12, 1), estimated_guests: 100)
  end

  test "is valid with a description and no date" do
    event_date = @event.event_dates.new(description: "Ensaio")

    assert event_date.valid?
  end

  test "requires a description" do
    event_date = @event.event_dates.new(description: "")

    assert_not event_date.valid?
    assert_includes event_date.errors[:description], "não pode ficar em branco"
  end

  test "upcoming and past scopes ignore undated milestones" do
    dated_future = @event.event_dates.create!(description: "Prova", date: Date.current + 5.days)
    @event.event_dates.create!(description: "Sem data")

    assert_equal [ dated_future ], @event.event_dates.upcoming.to_a
    assert_empty @event.event_dates.past.to_a
  end
end
