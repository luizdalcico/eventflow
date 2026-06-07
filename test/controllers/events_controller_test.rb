require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  test "show renders the four clickable summary cards for a wedding" do
    event = Event.create!(title: "Casamento Teste", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 100)
    event.guests.create!(name: "Convidado A", rsvp_status: "confirmed")
    event.guests.create!(name: "Convidado B", rsvp_status: "pending")
    event.godparents.create!(name: "Padrinho X")
    provider = Provider.create!(name: "Buffet", provider_type: "buffet", contact_name: "João", phone_number: "11999999999", document: "")
    event.event_providers.create!(provider: provider)
    event.manager_checklists.create!(task: "Interno pendente", completed: false)
    event.manager_checklists.create!(task: "Interno feito", completed: true)
    event.owner_checklists.create!(task: "Responsável pendente", completed: false)

    get event_url(event)

    assert_response :success
    # Four cards, each linking to its list/management page.
    assert_select "a[href=?]", event_guests_path(event)
    assert_select "a[href=?]", event_event_providers_path(event)
    assert_select "a[href=?]", event_manager_checklists_path(event)
    assert_select "a[href=?]", event_owner_checklists_path(event)
    # Card 1 shows the godparents line for a wedding.
    assert_select "dt", text: "Padrinhos"
  end

  test "show hides the godparents line for a non-wedding event" do
    event = Event.create!(title: "Aniversário", event_type: "adult_birthday", main_date: 1.month.from_now.to_date, estimated_guests: 50)

    get event_url(event)

    assert_response :success
    # Card 1 omits the godparents line outside weddings.
    assert_select "dt", text: "Padrinhos", count: 0
  end
end
