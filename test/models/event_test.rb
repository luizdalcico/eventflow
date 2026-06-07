require "test_helper"

class EventTest < ActiveSupport::TestCase
  def setup
    @event = Event.new(
      title: "Casamento Teste",
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
    assert_includes @event.errors[:event_type], "deve ser selecionado"
  end

  test "should require main_date" do
    @event.main_date = nil
    assert_not @event.valid?
    assert_includes @event.errors[:main_date], "deve ser informada"
  end

  test "should require estimated_guests" do
    @event.estimated_guests = nil
    assert_not @event.valid?
    assert_includes @event.errors[:estimated_guests], "deve ser informado"
  end

  test "should only accept valid event types" do
    @event.event_type = "invalid_type"
    assert_not @event.valid?
    assert_includes @event.errors[:event_type], "deve ser um tipo válido"
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
    assert_includes @event.errors[:estimated_guests], "deve ser maior que zero"
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

  test "contract_ready? is true only when every dynamic field is filled" do
    event = full_contract_event
    assert event.contract_ready?
    assert_empty event.missing_contract_fields
  end

  test "missing_contract_fields lists every blank contract field by label" do
    event = Event.create!(title: "Vazio", event_type: "wedding", main_date: Date.current + 1.month, estimated_guests: 80)

    missing = event.missing_contract_fields

    assert_not event.contract_ready?
    assert_includes missing, "Horário de início"
    assert_includes missing, "Horário de término"
    assert_includes missing, "Horas extras"
    assert_includes missing, "Valor total"
    assert_includes missing, "Valor da hora extra"
    assert_includes missing, "Data limite de pagamento"
    assert_includes missing, "Nº de recepcionistas"
    assert_includes missing, "Nome do contratante"
    assert_includes missing, "CPF do contratante"
  end

  test "missing_contract_fields flags the contratante CPF when absent" do
    event = full_contract_event
    event.event_owners.first.update!(cpf: nil)

    assert_equal [ "CPF do contratante" ], event.reload.missing_contract_fields
  end

  test "provider totals aggregate cost, professionals, paid and balance" do
    event = events(:future_event)
    contracted = Provider.create!(provider_type: "buffet", name: "Buffet A", document: "11111111000111", contact_name: "Ana", phone_number: "11999990000")
    paid = Provider.create!(provider_type: "cake", name: "Bolo B", document: "22222222000122", contact_name: "Bia", phone_number: "11999991111")

    event.event_providers.create!(provider: contracted, value: 1000, status: "contratado", professionals_count: 2)
    event.event_providers.create!(provider: paid, value: 500, status: "pago", professionals_count: 3)

    assert_equal BigDecimal("1500"), event.providers_total_cost
    assert_equal 5, event.providers_total_professionals
    assert_equal BigDecimal("500"), event.providers_paid_total
    assert_equal BigDecimal("1000"), event.providers_balance
  end

  test "provider totals are zero when there are no providers" do
    event = events(:past_event)
    assert_equal 0, event.providers_total_cost
    assert_equal 0, event.providers_total_professionals
    assert_equal 0, event.providers_balance
  end

  test "search matches the event title case-insensitively" do
    match = Event.create!(title: "Festa Junina XYZ", event_type: "corporate_event", main_date: Date.current + 1.month, estimated_guests: 10)
    other = Event.create!(title: "Outro Evento", event_type: "corporate_event", main_date: Date.current + 1.month, estimated_guests: 10)

    results = Event.search("festa junina")
    assert_includes results, match
    assert_not_includes results, other
  end

  test "search matches an owner name" do
    match = Event.create!(title: "Sem Nome Buscavel", event_type: "wedding", main_date: Date.current + 1.month, estimated_guests: 10)
    match.event_owners.create!(name: "Mariana Responsável", phone_number: "11999990000", email: "mariana@example.com")
    other = Event.create!(title: "Outro Sem Match", event_type: "wedding", main_date: Date.current + 1.month, estimated_guests: 10)

    results = Event.search("mariana")
    assert_includes results, match
    assert_not_includes results, other
  end

  test "search returns each event once even when multiple owners match" do
    event = Event.create!(title: "Casamento Dois Donos", event_type: "wedding", main_date: Date.current + 1.month, estimated_guests: 10)
    event.event_owners.create!(name: "Carlos Silva", phone_number: "11999990001", email: "carlos@example.com")
    event.event_owners.create!(name: "Carla Silva", phone_number: "11999990002", email: "carla@example.com")

    results = Event.search("silva")
    assert_equal 1, results.where(id: event.id).count
    assert_equal 1, results.to_a.count { |e| e.id == event.id }
  end

  test "search is a no-op when the query is blank" do
    assert_equal Event.count, Event.search("").count
    assert_equal Event.count, Event.search(nil).count
  end

  test "in_date_range this_week keeps only events within the current week" do
    inside = Event.create!(title: "Dentro Semana", event_type: "corporate_event", main_date: Date.current, estimated_guests: 10)
    outside = Event.create!(title: "Fora Semana", event_type: "corporate_event", main_date: Date.current.end_of_week + 1.day, estimated_guests: 10)

    results = Event.in_date_range("this_week")
    assert_includes results, inside
    assert_not_includes results, outside
  end

  test "in_date_range this_month keeps only events within the current month" do
    inside = Event.create!(title: "Dentro Mês", event_type: "corporate_event", main_date: Date.current.beginning_of_month, estimated_guests: 10)
    outside = Event.create!(title: "Fora Mês", event_type: "corporate_event", main_date: Date.current.next_month.beginning_of_month, estimated_guests: 10)

    results = Event.in_date_range("this_month")
    assert_includes results, inside
    assert_not_includes results, outside
  end

  test "in_date_range next_month keeps only events within the next month" do
    inside = Event.create!(title: "Dentro Próx Mês", event_type: "corporate_event", main_date: Date.current.next_month.beginning_of_month, estimated_guests: 10)
    outside = Event.create!(title: "Fora Próx Mês", event_type: "corporate_event", main_date: Date.current.beginning_of_month, estimated_guests: 10)

    results = Event.in_date_range("next_month")
    assert_includes results, inside
    assert_not_includes results, outside
  end

  test "in_date_range this_year keeps only events within the current year" do
    inside = Event.create!(title: "Dentro Ano", event_type: "corporate_event", main_date: Date.current.beginning_of_year, estimated_guests: 10)
    outside = Event.create!(title: "Fora Ano", event_type: "corporate_event", main_date: Date.current.next_year.beginning_of_year, estimated_guests: 10)

    results = Event.in_date_range("this_year")
    assert_includes results, inside
    assert_not_includes results, outside
  end

  test "in_date_range last_year keeps only events within the previous year" do
    inside = Event.create!(title: "Dentro Ano Passado", event_type: "corporate_event", main_date: Date.current.last_year.beginning_of_year, estimated_guests: 10)
    outside = Event.create!(title: "Fora Ano Passado", event_type: "corporate_event", main_date: Date.current.beginning_of_year, estimated_guests: 10)

    results = Event.in_date_range("last_year")
    assert_includes results, inside
    assert_not_includes results, outside
  end

  test "in_date_range next_year keeps only events within the following year" do
    inside = Event.create!(title: "Dentro Próx Ano", event_type: "corporate_event", main_date: Date.current.next_year.beginning_of_year, estimated_guests: 10)
    outside = Event.create!(title: "Fora Próx Ano", event_type: "corporate_event", main_date: Date.current.beginning_of_year, estimated_guests: 10)

    results = Event.in_date_range("next_year")
    assert_includes results, inside
    assert_not_includes results, outside
  end

  test "in_date_range is a no-op for blank or unknown periods" do
    assert_equal Event.count, Event.in_date_range("").count
    assert_equal Event.count, Event.in_date_range(nil).count
    assert_equal Event.count, Event.in_date_range("garbage").count
  end

  test "search and in_date_range compose" do
    match = Event.create!(title: "Festa Composta ABC", event_type: "corporate_event", main_date: Date.current.beginning_of_month, estimated_guests: 10)
    wrong_date = Event.create!(title: "Festa Composta ABC", event_type: "corporate_event", main_date: Date.current.next_month.beginning_of_month, estimated_guests: 10)
    wrong_name = Event.create!(title: "Festa Diferente", event_type: "corporate_event", main_date: Date.current.beginning_of_month, estimated_guests: 10)

    results = Event.search("composta abc").in_date_range("this_month")
    assert_includes results, match
    assert_not_includes results, wrong_date
    assert_not_includes results, wrong_name
  end

  test "creating a wedding generates a godparent list automatically" do
    event = Event.create!(title: "Casamento", event_type: "wedding",
                          main_date: Date.current + 1.month, estimated_guests: 100)
    assert event.godparent_list.present?
    assert event.godparent_list.token.present?
  end

  test "creating a non-wedding does not generate a godparent list" do
    event = Event.create!(title: "Festa", event_type: "adult_birthday",
                          main_date: Date.current + 1.month, estimated_guests: 50)
    assert_nil event.godparent_list
  end

  test "find_or_create_godparent_list! returns the existing list without creating another" do
    event = Event.create!(title: "Casamento", event_type: "wedding",
                          main_date: Date.current + 1.month, estimated_guests: 100)
    existing = event.godparent_list

    assert_no_difference -> { GodparentList.count } do
      assert_equal existing, event.find_or_create_godparent_list!
    end
  end

  test "find_or_create_godparent_list! builds a list for a wedding that lacks one" do
    event = Event.create!(title: "Casamento", event_type: "wedding",
                          main_date: Date.current + 1.month, estimated_guests: 100)
    # Simulate a wedding created before automatic generation existed.
    event.godparent_list.destroy!
    event.reload

    assert_difference -> { GodparentList.count }, 1 do
      list = event.find_or_create_godparent_list!
      assert list.token.present?
    end
  end

  test "find_or_create_godparent_list! is a no-op for non-weddings" do
    event = Event.create!(title: "Festa", event_type: "adult_birthday",
                          main_date: Date.current + 1.month, estimated_guests: 50)
    assert_nil event.find_or_create_godparent_list!
    assert_nil event.reload.godparent_list
  end

  # --- Guest list (every event type) ---

  test "creating any event generates a guest list automatically" do
    Event::EVENT_TYPES.each do |type|
      event = Event.create!(title: "Evento #{type}", event_type: type,
                            main_date: Date.current + 1.month, estimated_guests: 10)
      assert event.guest_list.present?, "#{type} should have a guest list"
      assert event.guest_list.token.present?
    end
  end

  test "find_or_create_guest_list! returns the existing list without creating another" do
    event = Event.create!(title: "Festa", event_type: "adult_birthday",
                          main_date: Date.current + 1.month, estimated_guests: 50)
    existing = event.guest_list

    assert_no_difference -> { GuestList.count } do
      assert_equal existing, event.find_or_create_guest_list!
    end
  end

  test "find_or_create_guest_list! builds a list for an event that lacks one" do
    event = Event.create!(title: "Festa", event_type: "adult_birthday",
                          main_date: Date.current + 1.month, estimated_guests: 50)
    # Simulate an event created before automatic generation existed.
    event.guest_list.destroy!
    event.reload

    assert_difference -> { GuestList.count }, 1 do
      list = event.find_or_create_guest_list!
      assert list.token.present?
    end
  end

  # --- Family-member list (weddings only) ---

  test "creating a wedding generates a family-member list automatically" do
    event = Event.create!(title: "Casamento", event_type: "wedding",
                          main_date: Date.current + 1.month, estimated_guests: 100)
    assert event.family_member_list.present?
    assert event.family_member_list.token.present?
  end

  test "creating a non-wedding does not generate a family-member list" do
    event = Event.create!(title: "Festa", event_type: "adult_birthday",
                          main_date: Date.current + 1.month, estimated_guests: 50)
    assert_nil event.family_member_list
  end

  test "find_or_create_family_member_list! builds a list for a wedding that lacks one" do
    event = Event.create!(title: "Casamento", event_type: "wedding",
                          main_date: Date.current + 1.month, estimated_guests: 100)
    event.family_member_list.destroy!
    event.reload

    assert_difference -> { FamilyMemberList.count }, 1 do
      list = event.find_or_create_family_member_list!
      assert list.token.present?
    end
  end

  test "find_or_create_family_member_list! is a no-op for non-weddings" do
    event = Event.create!(title: "Festa", event_type: "adult_birthday",
                          main_date: Date.current + 1.month, estimated_guests: 50)
    assert_nil event.find_or_create_family_member_list!
    assert_nil event.reload.family_member_list
  end

  private

  # Event with every dynamic contract field (and a complete contratante) filled.
  def full_contract_event
    event = Event.create!(
      title: "Completo", event_type: "wedding", main_date: Date.current + 1.month,
      estimated_guests: 80, start_time: "20:00", end_time: "23:00", extra_hours: 2,
      contract_total_value: 5000, contract_extra_hour_rate: 250,
      contract_payment_due_date: Date.current + 2.weeks, contract_receptionists_count: 3
    )
    event.event_owners.create!(name: "João", cpf: "12345678901", phone_number: "11999999999", email: "joao@example.com")
    event
  end
end
