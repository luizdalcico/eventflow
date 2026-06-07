require "test_helper"

class EventOwnerTest < ActiveSupport::TestCase
  setup do
    @event = Event.create!(title: "Casamento Teste", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 100)
  end

  test "persists the extended contractor fields" do
    owner = @event.event_owners.create!(
      name: "Maria Noiva",
      email: "maria@example.com",
      phone_number: "11999999999",
      address: "Rua das Flores, 100, Centro, São Paulo",
      mother_name: "Joana Silva",
      father_name: "José Silva",
      birth_date: Date.new(1990, 5, 20),
      instagram: "maria.noiva"
    )

    owner.reload
    assert_equal "Rua das Flores, 100, Centro, São Paulo", owner.address
    assert_equal "Joana Silva", owner.mother_name
    assert_equal "José Silva", owner.father_name
    assert_equal Date.new(1990, 5, 20), owner.birth_date
    assert_equal "maria.noiva", owner.instagram
  end

  test "strips a leading @ from the instagram handle" do
    owner = @event.event_owners.create!(
      name: "João",
      email: "joao@example.com",
      phone_number: "11999999999",
      instagram: "  @joao.silva  "
    )

    assert_equal "joao.silva", owner.reload.instagram
  end

  test "leaves a bare instagram handle untouched" do
    owner = @event.event_owners.create!(
      name: "Ana",
      email: "ana@example.com",
      phone_number: "11999999999",
      instagram: "ana_eventos"
    )

    assert_equal "ana_eventos", owner.reload.instagram
  end

  test "find_reusable_by_cpf returns the most recent owner with that CPF across events" do
    older_event = Event.create!(title: "Outro Evento", event_type: "wedding", main_date: 2.months.from_now.to_date, estimated_guests: 50)
    older = older_event.event_owners.create!(name: "Maria Antiga", email: "antiga@example.com", phone_number: "11999999999", cpf: "12345678901")
    newer = @event.event_owners.create!(name: "Maria Nova", email: "nova@example.com", phone_number: "11888888888", cpf: "12345678901")

    assert older.created_at <= newer.created_at
    assert_equal newer, EventOwner.find_reusable_by_cpf("12345678901")
  end

  test "find_reusable_by_cpf sanitizes a masked CPF before matching" do
    owner = @event.event_owners.create!(name: "José", email: "jose@example.com", phone_number: "11999999999", cpf: "98765432100")

    assert_equal owner, EventOwner.find_reusable_by_cpf("987.654.321-00")
  end

  test "find_reusable_by_cpf returns nil for a partial or unknown CPF" do
    @event.event_owners.create!(name: "José", email: "jose@example.com", phone_number: "11999999999", cpf: "98765432100")

    assert_nil EventOwner.find_reusable_by_cpf("987654")
    assert_nil EventOwner.find_reusable_by_cpf("00000000000")
    assert_nil EventOwner.find_reusable_by_cpf(nil)
  end

  test "by_cpf scope filters owners by CPF" do
    match = @event.event_owners.create!(name: "Com CPF", email: "com@example.com", phone_number: "11999999999", cpf: "11122233344")
    @event.event_owners.create!(name: "Outro CPF", email: "outro@example.com", phone_number: "11888888888", cpf: "55566677788")

    assert_equal [ match ], EventOwner.by_cpf("11122233344").to_a
  end
end
