require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  test "index makes the whole event card clickable via a stretched link to the event" do
    event = Event.create!(title: "Festa", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 70)

    get events_url

    assert_response :success
    # The title anchor stretches over the whole card (after:inset-0), so the entire
    # card navigates to the event while staying a single navigation anchor.
    assert_select "a[href=?].after\\:inset-0", event_path(event)
    # Footer actions stay reachable as their own links.
    assert_select "a[href=?]", edit_event_path(event)
  end

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

  test "contract returns a PDF attachment" do
    event = Event.create!(title: "Contrato", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 80, contract_total_value: 5000, contract_receptionists_count: 3)
    event.event_owners.create!(name: "João", cpf: "12345678901", phone_number: "11999999999", email: "joao@example.com")

    get contract_event_url(event, format: :pdf)

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_match(/attachment/, response.headers["Content-Disposition"])
    assert_match(/contrato_#{event.id}_/, response.headers["Content-Disposition"])
    assert_equal "%PDF-", response.body[0, 5]
  end

  test "create persists contract fields" do
    assert_difference "Event.count", 1 do
      post events_url, params: { event: {
        title: "Novo Contrato", event_type: "wedding", main_date: 1.month.from_now.to_date,
        estimated_guests: 90,
        contract_total_value: "7500.50", contract_extra_hour_rate: "300.0",
        contract_payment_due_date: "2026-08-15", contract_receptionists_count: "5"
      } }
    end

    event = Event.order(:created_at).last
    assert_equal 7500.50, event.contract_total_value.to_f
    assert_equal 300.0, event.contract_extra_hour_rate.to_f
    assert_equal Date.new(2026, 8, 15), event.contract_payment_due_date
    assert_equal 5, event.contract_receptionists_count
  end

  test "index without filters lists every event" do
    a = Event.create!(title: "Evento Index A", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 50)
    b = Event.create!(title: "Evento Index B", event_type: "wedding", main_date: 2.months.ago.to_date, estimated_guests: 50)

    get events_url

    assert_response :success
    assert_select "body", text: /#{a.title}/
    assert_select "body", text: /#{b.title}/
  end

  test "index filters by search query across title and owner name" do
    by_title = Event.create!(title: "Casório Tabajara", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 50)
    by_owner = Event.create!(title: "Evento Genérico", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 50)
    by_owner.event_owners.create!(name: "Tabajara Souza", phone_number: "11999990000", email: "tab@example.com")
    miss = Event.create!(title: "Nada A Ver", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 50)

    get events_url, params: { q: "tabajara" }

    assert_response :success
    assert_select "body", text: /#{by_title.title}/
    assert_select "body", text: /#{by_owner.title}/
    assert_select "body", { text: /#{miss.title}/, count: 0 }
  end

  test "index filters by date period" do
    this_month = Event.create!(title: "Deste Mês Filtro", event_type: "wedding", main_date: Date.current.beginning_of_month, estimated_guests: 50)
    next_month = Event.create!(title: "Próximo Mês Filtro", event_type: "wedding", main_date: Date.current.next_month.beginning_of_month, estimated_guests: 50)

    get events_url, params: { period: "this_month" }

    assert_response :success
    assert_select "body", text: /#{this_month.title}/
    assert_select "body", { text: /#{next_month.title}/, count: 0 }
  end

  test "index composes search and date filters" do
    match = Event.create!(title: "Combo Match", event_type: "wedding", main_date: Date.current.beginning_of_month, estimated_guests: 50)
    wrong_date = Event.create!(title: "Combo Match", event_type: "wedding", main_date: Date.current.next_month.beginning_of_month, estimated_guests: 50)

    get events_url, params: { q: "combo match", period: "this_month" }

    assert_response :success
    assert_select "body", text: /#{match.title}/
    # Same title, out of the date range — must be excluded.
    assert_equal 1, response.body.scan("Combo Match").size
    assert_not_nil wrong_date
  end

  test "update persists contract fields" do
    event = Event.create!(title: "Editar", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 60)

    patch event_url(event), params: { event: {
      contract_total_value: "1200.00", contract_receptionists_count: "2"
    } }

    event.reload
    assert_equal 1200.0, event.contract_total_value.to_f
    assert_equal 2, event.contract_receptionists_count
  end
end
