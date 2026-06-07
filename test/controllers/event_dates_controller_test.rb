require "test_helper"

class EventDatesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.new(2026, 12, 1), estimated_guests: 100)
  end

  test "index shows the apply-template button when a template exists" do
    get event_event_dates_url(@event)

    assert_response :success
    assert_select "form[action=?]", apply_template_event_event_dates_path(@event)
  end

  test "index hides the apply-template button when no template exists" do
    event = Event.create!(title: "Bodas", event_type: "bodas",
                          main_date: Date.new(2026, 12, 1), estimated_guests: 30)

    get event_event_dates_url(event)

    assert_response :success
    assert_select "form[action=?]", apply_template_event_event_dates_path(event), count: 0
  end

  test "apply_template seeds the event dates from the catalog" do
    assert_difference -> { @event.event_dates.count }, DateTemplate.items_for("wedding").size do
      post apply_template_event_event_dates_url(@event), as: :turbo_stream
    end

    assert_response :success
    assert @event.event_dates.exists?(description: "Entrega/envio dos convites")
    # Os marcos são semeados sem data, para o usuário preencher depois.
    assert @event.event_dates.all? { |event_date| event_date.date.nil? }
  end

  test "create persists a date milestone without a date" do
    assert_difference -> { @event.event_dates.count }, 1 do
      post event_event_dates_url(@event), as: :turbo_stream,
           params: { event_date: { description: "Ensaio", date: "" } }
    end

    assert_response :success
    assert_nil @event.event_dates.find_by!(description: "Ensaio").date
  end

  test "apply_template is idempotent on re-post" do
    post apply_template_event_event_dates_url(@event), as: :turbo_stream

    assert_no_difference -> { @event.event_dates.count } do
      post apply_template_event_event_dates_url(@event), as: :turbo_stream
    end
    assert_response :success
  end
end
