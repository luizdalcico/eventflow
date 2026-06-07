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
end
