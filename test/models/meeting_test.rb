require "test_helper"

class MeetingTest < ActiveSupport::TestCase
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
  end

  test "requires a date" do
    meeting = @event.meetings.new(date: nil)
    assert_not meeting.valid?
    assert_includes meeting.errors[:date], I18n.t("errors.messages.blank")
  end

  test "valid with a date" do
    meeting = @event.meetings.new(date: Date.current, participants: "Marina", summary: "Resumo")
    assert meeting.valid?
  end

  test "ordered returns most recent meetings first" do
    older = @event.meetings.create!(date: Date.current - 5.days)
    newer = @event.meetings.create!(date: Date.current)
    assert_equal [ newer, older ], @event.meetings.ordered.to_a
  end

  test "destroying a meeting nullifies its pendencies instead of deleting them" do
    meeting = @event.meetings.create!(date: Date.current)
    pendency = @event.pendencies.create!(description: "Item", meeting: meeting)

    assert_difference -> { @event.pendencies.count }, 0 do
      meeting.destroy
    end
    assert_nil pendency.reload.meeting_id
  end
end
