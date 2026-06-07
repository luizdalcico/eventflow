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

  test "persists contract fields" do
    event = Event.create!(
      title: "Casamento Contrato",
      event_type: "wedding",
      main_date: Date.current + 1.month,
      estimated_guests: 100,
      contract_total_value: 12_345.67,
      contract_extra_hour_rate: 250.0,
      contract_payment_due_date: Date.new(2026, 8, 1),
      contract_receptionists_count: 4
    )

    event.reload
    assert_equal 12_345.67, event.contract_total_value.to_f
    assert_equal 250.0, event.contract_extra_hour_rate.to_f
    assert_equal Date.new(2026, 8, 1), event.contract_payment_due_date
    assert_equal 4, event.contract_receptionists_count
  end

  test "contract fields are optional" do
    @event.title = "Sem Contrato"
    assert @event.valid?, @event.errors.full_messages.to_sentence
  end

  test "rejects negative contract_total_value" do
    @event.contract_total_value = -1
    assert_not @event.valid?
    assert_includes @event.errors[:contract_total_value], "deve ser maior ou igual a 0"
  end

  test "rejects negative contract_extra_hour_rate" do
    @event.contract_extra_hour_rate = -1
    assert_not @event.valid?
    assert_includes @event.errors[:contract_extra_hour_rate], "deve ser maior ou igual a 0"
  end

  test "rejects negative contract_receptionists_count" do
    @event.contract_receptionists_count = -1
    assert_not @event.valid?
    assert_includes @event.errors[:contract_receptionists_count], "deve ser maior ou igual a 0"
  end

  test "rejects non-integer contract_receptionists_count" do
    @event.contract_receptionists_count = 2.5
    assert_not @event.valid?
    assert_includes @event.errors[:contract_receptionists_count], "deve ser um número inteiro"
  end

  test "accepts blank contract numeric fields" do
    @event.title = "Sem Valores"
    @event.contract_total_value = nil
    @event.contract_extra_hour_rate = nil
    @event.contract_receptionists_count = nil
    assert @event.valid?, @event.errors.full_messages.to_sentence
  end
end
