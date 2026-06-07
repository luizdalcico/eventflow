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

  test "index defaults to upcoming events and hides past events" do
    upcoming = Event.create!(title: "Futuro", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 50)
    past = Event.create!(title: "Antigo", event_type: "wedding", main_date: 1.month.ago.to_date, estimated_guests: 50)

    get events_url

    assert_response :success
    assert_select "a[href=?]", event_path(upcoming)
    assert_select "a[href=?]", event_path(past), count: 0
  end

  test "index with filter=past renders past events and hides upcoming" do
    upcoming = Event.create!(title: "Futuro", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 50)
    past = Event.create!(title: "Antigo", event_type: "wedding", main_date: 1.month.ago.to_date, estimated_guests: 50)

    get events_url(filter: "past")

    assert_response :success
    assert_select "a[href=?]", event_path(past)
    assert_select "a[href=?]", event_path(upcoming), count: 0
  end

  test "index with filter=all renders both upcoming and past events" do
    upcoming = Event.create!(title: "Futuro", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 50)
    past = Event.create!(title: "Antigo", event_type: "wedding", main_date: 1.month.ago.to_date, estimated_guests: 50)

    get events_url(filter: "all")

    assert_response :success
    assert_select "a[href=?]", event_path(upcoming)
    assert_select "a[href=?]", event_path(past)
  end

  test "index summary cards always link to each filter with full counts" do
    Event.create!(title: "Futuro", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 50)
    Event.create!(title: "Antigo", event_type: "wedding", main_date: 1.month.ago.to_date, estimated_guests: 50)

    upcoming_count = Event.upcoming.count
    past_count = Event.past.count
    total_count = upcoming_count + past_count

    get events_url(filter: "past")

    assert_response :success
    # Cards stay clickable to switch views regardless of the active filter.
    assert_select "a[href=?]", events_path(filter: "all")
    assert_select "a[href=?]", events_path(filter: "upcoming")
    assert_select "a[href=?]", events_path(filter: "past")
    # Counts reflect the whole dataset, not the filtered list.
    assert_select "a[href=?]", events_path(filter: "all"), text: /#{total_count}.*Total/m
    assert_select "a[href=?]", events_path(filter: "upcoming"), text: /#{upcoming_count}.*Próximos/m
    assert_select "a[href=?]", events_path(filter: "past"), text: /#{past_count}.*Passados/m
  end

  test "index with an invalid filter falls back to the upcoming default" do
    upcoming = Event.create!(title: "Futuro", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 50)
    past = Event.create!(title: "Antigo", event_type: "wedding", main_date: 1.month.ago.to_date, estimated_guests: 50)

    get events_url(filter: "'; DROP TABLE events; --")

    assert_response :success
    assert_select "a[href=?]", event_path(upcoming)
    assert_select "a[href=?]", event_path(past), count: 0
  end

  test "show renders the clickable summary cards for a wedding" do
    event = Event.create!(title: "Casamento Teste", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 100)
    event.guests.create!(name: "Convidado A", rsvp_status: "confirmed")
    event.guests.create!(name: "Convidado B", rsvp_status: "pending")
    provider = Provider.create!(name: "Buffet", provider_type: "buffet", contact_name: "João", phone_number: "11999999999", document: "")
    event.event_providers.create!(provider: provider)
    event.manager_checklists.create!(task: "Interno pendente", completed: false)
    event.manager_checklists.create!(task: "Interno feito", completed: true)
    event.owner_checklists.create!(task: "Responsável pendente", completed: false)

    get event_url(event)

    assert_response :success
    # Each card links to its list/management page.
    assert_select "a[href=?]", event_guests_path(event)
    assert_select "a[href=?]", event_event_providers_path(event)
    assert_select "a[href=?]", event_manager_checklists_path(event)
    assert_select "a[href=?]", event_owner_checklists_path(event)
    assert_select "a[href=?]", event_cortejo_path(event)
  end

  test "show no longer renders the godparents section on the event page" do
    event = Event.create!(title: "Casamento Teste", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 100)
    event.godparents.create!(name: "Padrinho X")

    get event_url(event)

    assert_response :success
    # Padrinhos moved to the guests tabs; the show page no longer mentions it.
    assert_select "dt", text: "Padrinhos", count: 0
    assert_select "h2", text: "Lista de Padrinhos", count: 0
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

  test "index with filter=all and no search lists every event" do
    a = Event.create!(title: "Evento Index A", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 50)
    b = Event.create!(title: "Evento Index B", event_type: "wedding", main_date: 2.months.ago.to_date, estimated_guests: 50)

    get events_url(filter: "all")

    assert_response :success
    assert_select "body", text: /#{a.title}/
    assert_select "body", text: /#{b.title}/
  end

  test "index wires the filter form to auto-submit via Stimulus targeting the list frame" do
    get events_url

    assert_response :success
    # The form auto-applies filters through the autosave controller (no manual button)
    # and targets the events_list Turbo Frame so the search input keeps focus.
    assert_select "form[data-controller=?][data-action*=?][data-turbo-frame=?]", "autosave", "autosave#save", "events_list"
  end

  test "index wraps the event listing in a top-targeting Turbo Frame" do
    Event.create!(title: "Festa Frame", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 30)

    get events_url

    assert_response :success
    # The listing lives in the frame; target=_top keeps card links full-page.
    assert_select "turbo-frame#events_list[target=_top]"
    assert_select "turbo-frame#events_list a[href=?]", event_path(Event.last)
  end

  test "index offers the year-based date filter options" do
    get events_url

    assert_response :success
    assert_select "select[name=period] option[value=last_year]", text: "Ano passado"
    assert_select "select[name=period] option[value=next_year]", text: "Próximo ano"
  end

  test "index filters by last_year period" do
    last_year = Event.create!(title: "Evento Ano Passado", event_type: "wedding", main_date: Date.current.last_year.beginning_of_year, estimated_guests: 50)
    this_year = Event.create!(title: "Evento Este Ano", event_type: "wedding", main_date: Date.current.beginning_of_year, estimated_guests: 50)

    # last_year events are in the past, so view them through the "all" card filter.
    get events_url, params: { period: "last_year", filter: "all" }

    assert_response :success
    assert_select "body", text: /#{last_year.title}/
    assert_select "body", { text: /#{this_year.title}/, count: 0 }
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

    get events_url, params: { period: "this_month", filter: "all" }

    assert_response :success
    assert_select "body", text: /#{this_month.title}/
    assert_select "body", { text: /#{next_month.title}/, count: 0 }
  end

  test "index composes search and date filters" do
    match = Event.create!(title: "Combo Match", event_type: "wedding", main_date: Date.current.beginning_of_month, estimated_guests: 50)
    wrong_date = Event.create!(title: "Combo Match", event_type: "wedding", main_date: Date.current.next_month.beginning_of_month, estimated_guests: 50)

    get events_url, params: { q: "combo match", period: "this_month", filter: "all" }

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
