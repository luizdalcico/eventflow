require "test_helper"

class MeetingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
  end

  test "index renders meetings and the general pendencies section" do
    @event.meetings.create!(date: Date.current, participants: "Marina")

    get event_meetings_url(@event)
    assert_response :success
    assert_select "h1", text: "Reuniões & pendências"
    assert_select "#meetings"
    assert_select "#general_pendencies"
  end

  test "index shows the empty state when there are no meetings" do
    get event_meetings_url(@event)
    assert_response :success
    assert_select "#meetings_empty"
  end

  test "show renders the meeting and its pendencies" do
    meeting = @event.meetings.create!(date: Date.current)
    @event.pendencies.create!(description: "Enviar contrato", meeting: meeting)

    get event_meeting_url(@event, meeting)
    assert_response :success
    assert_select "#meeting_#{meeting.id}_pendencies"
  end

  test "create persists the meeting" do
    assert_difference -> { @event.meetings.count }, 1 do
      post event_meetings_url(@event), as: :turbo_stream,
           params: { meeting: { date: Date.current, participants: "Marina, Ana", summary: "Cronograma" } }
    end
    assert_response :success
    meeting = @event.meetings.last
    assert_equal "Marina, Ana", meeting.participants
    assert_equal "Cronograma", meeting.summary
  end

  test "create with a blank date does not persist" do
    assert_no_difference -> { @event.meetings.count } do
      post event_meetings_url(@event), as: :turbo_stream,
           params: { meeting: { date: "" } }
    end
    assert_response :success
  end

  test "update persists the new values" do
    meeting = @event.meetings.create!(date: Date.current, participants: "Antigo")

    patch event_meeting_url(@event, meeting),
          params: { meeting: { participants: "Novo", summary: "Decisões" } }
    assert_response :no_content

    meeting.reload
    assert_equal "Novo", meeting.participants
    assert_equal "Decisões", meeting.summary
  end

  test "destroy removes the meeting" do
    meeting = @event.meetings.create!(date: Date.current)

    assert_difference -> { @event.meetings.count }, -1 do
      delete event_meeting_url(@event, meeting), as: :turbo_stream
    end
    assert_response :success
  end

  test "meetings are scoped to their event" do
    other = Event.create!(title: "Outro", event_type: "wedding",
                          main_date: Date.current + 2.months, estimated_guests: 50)
    meeting = other.meetings.create!(date: Date.current)

    get event_meeting_url(@event, meeting)
    assert_response :not_found
  end
end
