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

  test "index creates the godparent list for a wedding that lacks one and shows its link" do
    @event.godparent_list.destroy! # wedding created before automatic generation
    @event.reload

    assert_difference -> { GodparentList.count }, 1 do
      get event_guests_path(@event)
    end
    assert_response :success
    # Shows the ready-to-share link panel, not a "generate link" form.
    assert_select "input[value=?]", godparent_list_url(@event.reload.godparent_list.token)
    assert_select "input[type=submit][value=?]", "Gerar link de preenchimento", count: 0
  end

  test "index shows the compact public link panels without expiration controls" do
    get event_guests_path(@event)
    assert_response :success
    # Ready-to-share links for the three audiences.
    assert_select "input[value=?]", guest_list_url(@event.guest_list.token)
    assert_select "input[value=?]", family_member_list_url(@event.family_member_list.token)
    assert_select "input[value=?]", godparent_list_url(@event.godparent_list.token)
    # No expiration UI anymore.
    assert_no_match "Alterar expiração", @response.body
    assert_no_match "Expira em", @response.body
    # Each panel offers an "Abrir" link that opens the public page in a new tab.
    assert_select "a[target=_blank][href=?]", guest_list_url(@event.guest_list.token), text: "Abrir"
    assert_select "a[target=_blank][href=?]", family_member_list_url(@event.family_member_list.token), text: "Abrir"
    assert_select "a[target=_blank][href=?]", godparent_list_url(@event.godparent_list.token), text: "Abrir"
  end

  test "non-wedding events get a guest link panel but no family link panel" do
    party = Event.create!(title: "Aniversário", event_type: "adult_birthday",
                          main_date: Date.current + 1.month, estimated_guests: 50)

    get event_guests_path(party)
    assert_response :success
    assert_select "input[value=?]", guest_list_url(party.guest_list.token)
    assert_nil party.family_member_list
    assert_select "h2", text: "Link público de familiares", count: 0
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
