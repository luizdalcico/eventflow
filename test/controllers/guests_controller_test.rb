require "test_helper"

class GuestsControllerTest < ActionDispatch::IntegrationTest
  XLSX_TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet".freeze

  def setup
    @event = Event.create!(title: "Casamento", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
    @guest = @event.guests.create!(name: "João", guest_type: "adult", party_size: 2)
  end

  test "index renders the adult and child counts" do
    @event.guests.create!(name: "Lucas", guest_type: "child", party_size: 1)

    get event_guests_path(@event)
    assert_response :success
    assert_select "th", text: "Tipo"
    assert_match "adultos", @response.body
    assert_match "crianças", @response.body
  end

  test "index renders convidados, padrinhos and familiares tabs for weddings" do
    get event_guests_path(@event)
    assert_response :success
    assert_select "[data-testid=?]", "tab-convidados"
    assert_select "[data-testid=?]", "tab-padrinhos"
    assert_select "[data-testid=?]", "tab-familiares"
  end

  test "index has no padrinhos or familiares tabs for non-wedding events" do
    party = Event.create!(title: "Aniversário", event_type: "adult_birthday",
                          main_date: Date.current + 1.month, estimated_guests: 50)
    party.guests.create!(name: "Ana", guest_type: "adult", party_size: 1)

    get event_guests_path(party)
    assert_response :success
    assert_select "[data-testid=?]", "tab-padrinhos", count: 0
    assert_select "[data-testid=?]", "tab-familiares", count: 0
    # A lista geral continua visível.
    assert_select "th", text: "Tipo"
  end

  test "update persists guest_type" do
    patch event_guest_path(@event, @guest), params: { guest: { guest_type: "child" } }
    assert_response :ok
    assert_equal "child", @guest.reload.guest_type
  end

  test "export returns an xlsx file" do
    get export_event_guests_path(@event)
    assert_response :success
    assert_equal XLSX_TYPE, @response.media_type
  end

  test "print renders the printable list" do
    get print_event_guests_path(@event)
    assert_response :success
    assert_match "Lista de convidados", @response.body
    assert_match @guest.name, @response.body
  end
end
