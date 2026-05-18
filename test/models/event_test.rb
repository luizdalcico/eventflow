require "test_helper"

class EventTest < ActiveSupport::TestCase
  def setup
    @event = Event.new(
      event_type: "wedding",
      main_date: Date.current + 1.month,
      estimated_guests: 100
    )
  end

  test "should be valid with valid attributes" do
    assert @event.valid?
  end

  test "should require event_type" do
    @event.event_type = nil
    assert_not @event.valid?
    assert_includes @event.errors[:event_type], "can't be blank"
  end

  test "should require main_date" do
    @event.main_date = nil
    assert_not @event.valid?
    assert_includes @event.errors[:main_date], "can't be blank"
  end

  test "should require estimated_guests" do
    @event.estimated_guests = nil
    assert_not @event.valid?
    assert_includes @event.errors[:estimated_guests], "can't be blank"
  end

  test "should only accept valid event types" do
    @event.event_type = "invalid_type"
    assert_not @event.valid?
    assert_includes @event.errors[:event_type], "is not included in the list"
  end

  test "should accept valid event types" do
    Event::EVENT_TYPES.each do |type|
      @event.event_type = type
      assert @event.valid?, "#{type} should be valid"
    end
  end

  test "should validate estimated_guests is positive" do
    @event.estimated_guests = 0
    assert_not @event.valid?
    assert_includes @event.errors[:estimated_guests], "must be greater than 0"
  end

  test "should validate end_time is after start_time" do
    @event.start_time = "20:00"
    @event.end_time = "18:00"
    assert_not @event.valid?
    assert_includes @event.errors[:end_time], "deve ser após o horário de início"
  end

  test "should be valid when end_time is after start_time" do
    @event.start_time = "18:00"
    @event.end_time = "22:00"
    assert @event.valid?
  end

  test "upcoming scope should return future events" do
    past_event = events(:past_event) if events(:past_event)
    future_event = events(:future_event) if events(:future_event)
    
    upcoming = Event.upcoming
    assert_not_includes upcoming, past_event if past_event
    assert_includes upcoming, future_event if future_event
  end

  test "wedding? should return true for wedding events" do
    @event.event_type = "wedding"
    assert @event.wedding?
  end

  test "birthday? should return true for birthday events" do
    @event.event_type = "adult_birthday"
    assert @event.birthday?
    
    @event.event_type = "children_birthday"
    assert @event.birthday?
  end

  test "corporate? should return true for corporate events" do
    @event.event_type = "corporate_event"
    assert @event.corporate?
  end
end
