require "test_helper"

class EventOwnersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = Event.create!(title: "Casamento Teste", event_type: "wedding", main_date: 1.month.from_now.to_date, estimated_guests: 100)
  end

  test "create persists the extended contractor fields" do
    assert_difference -> { @event.event_owners.count }, 1 do
      post event_event_owners_url(@event), params: { event_owner: {
        name: "Maria Noiva",
        email: "maria@example.com",
        phone_number: "11999999999",
        address: "Rua das Flores, 100",
        mother_name: "Joana Silva",
        father_name: "José Silva",
        birth_date: "1990-05-20",
        instagram: "@maria.noiva"
      } }
    end

    owner = @event.event_owners.order(:created_at).last
    assert_equal "Rua das Flores, 100", owner.address
    assert_equal "Joana Silva", owner.mother_name
    assert_equal "José Silva", owner.father_name
    assert_equal Date.new(1990, 5, 20), owner.birth_date
    assert_equal "maria.noiva", owner.instagram
    assert_redirected_to [@event, owner]
  end

  test "update changes the extended contractor fields" do
    owner = @event.event_owners.create!(name: "João", email: "joao@example.com", phone_number: "11999999999")

    patch event_event_owner_url(@event, owner), params: { event_owner: {
      address: "Av. Brasil, 200",
      mother_name: "Marta",
      father_name: "Pedro",
      birth_date: "1985-12-01",
      instagram: "joao_eventos"
    } }

    owner.reload
    assert_equal "Av. Brasil, 200", owner.address
    assert_equal "Marta", owner.mother_name
    assert_equal "Pedro", owner.father_name
    assert_equal Date.new(1985, 12, 1), owner.birth_date
    assert_equal "joao_eventos", owner.instagram
    assert_redirected_to [@event, owner]
  end

  test "form renders the extended contractor field inputs" do
    get new_event_event_owner_url(@event)

    assert_response :success
    assert_select "input[name=?]", "event_owner[address]"
    assert_select "input[name=?]", "event_owner[mother_name]"
    assert_select "input[name=?]", "event_owner[father_name]"
    assert_select "input[name=?]", "event_owner[birth_date]"
    assert_select "input[name=?]", "event_owner[instagram]"
  end
end
