require "test_helper"

class GuestListFlowTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(
      title: "Festa Teste",
      event_type: "adult_birthday",
      main_date: Date.current + 1.month,
      estimated_guests: 50
    )
  end

  # --- Auto-geração para qualquer tipo de evento ---

  test "a guest list is generated automatically for every event type" do
    assert @event.guest_list.present?
    assert @event.guest_list.token.present?
  end

  # --- Admin: atualizar o link da lista (já existente) ---

  test "admin sets an expiry on the existing list without creating a new one" do
    assert_no_difference -> { GuestList.count } do
      post event_guest_list_path(@event), params: { guest_list: { expires_at: 1.week.from_now } }
    end
    assert_redirected_to event_guests_path(@event)
    list = @event.reload.guest_list
    assert list.token.present?
    assert list.expires_at.present?
  end

  test "posting twice reuses the same list" do
    post event_guest_list_path(@event), params: { guest_list: {} }
    first = @event.reload.guest_list
    post event_guest_list_path(@event), params: { guest_list: {} }
    assert_equal first.id, @event.reload.guest_list.id
  end

  # --- Público: acesso por token ---

  test "public page renders for a valid token" do
    list = list_expiring(1.week.from_now)
    get guest_list_path(list.token)
    assert_response :success
    assert_select "h1", text: @event.title
  end

  test "invalid token returns not found" do
    get guest_list_path("does-not-exist")
    assert_response :not_found
  end

  test "expired token returns gone" do
    list = list_expiring(1.day.ago)
    get guest_list_path(list.token)
    assert_response :gone
  end

  # --- Convidados: criar / atualizar / remover ---

  test "creating a guest adds a row to the event" do
    list = list_expiring(1.week.from_now)
    assert_difference -> { @event.guests.count }, 1 do
      post guest_list_guests_path(list.token), as: :turbo_stream
    end
    assert_response :success
  end

  test "updating a guest saves the submitted attributes" do
    list = list_expiring(1.week.from_now)
    guest = @event.guests.create!

    patch guest_list_guest_path(list.token, guest), params: {
      guest: { name: "Ana", party_size: 2, phone_number: "(11) 99999-0000", guest_type: "child", notes: "Mesa 3" }
    }
    assert_response :success

    guest.reload
    assert_equal "Ana", guest.name
    assert_equal 2, guest.party_size
    assert_equal "11999990000", guest.phone_number
    assert_equal "child", guest.guest_type
    assert_equal "Mesa 3", guest.notes
  end

  test "destroying a guest removes the row" do
    list = list_expiring(1.week.from_now)
    guest = @event.guests.create!

    assert_difference -> { @event.guests.count }, -1 do
      delete guest_list_guest_path(list.token, guest), as: :turbo_stream
    end
  end

  # --- Finalizar trava a edição ---

  test "finalize locks the list against further writes" do
    list = list_expiring(1.week.from_now)
    patch finalize_guest_list_path(list.token)
    assert list.reload.submitted?

    assert_no_difference -> { @event.guests.count } do
      post guest_list_guests_path(list.token), as: :turbo_stream
    end
    assert_response :forbidden
  end

  private

  # Reuses the list auto-generated on event creation, applying an expiry.
  def list_expiring(expires_at)
    @event.guest_list.tap { |list| list.update!(expires_at: expires_at) }
  end
end
