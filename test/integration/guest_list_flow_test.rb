require "test_helper"

class GuestListFlowTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(
      title: "Festa Teste",
      event_type: "adult_birthday",
      main_date: Date.current + 1.month,
      estimated_guests: 50
    )
    @list = @event.guest_list
  end

  # --- Auto-geração para qualquer tipo de evento ---

  test "a guest list is generated automatically for every event type" do
    assert @list.present?
    assert @list.token.present?
  end

  # --- Público: acesso por token ---

  test "public page renders for a valid token" do
    get guest_list_path(@list.token)
    assert_response :success
    assert_select "h1", text: @event.title
  end

  test "invalid token returns not found" do
    get guest_list_path("nope")
    assert_response :not_found
  end

  test "public page reuses the guests table and the import block" do
    @event.guests.create!(name: "João", party_size: 2)
    get guest_list_path(@list.token)
    assert_response :success
    # Mesma tabela do painel do cerimonial.
    assert_select "tbody#guests_body tr#guest_#{@event.guests.first.id}"
    # Bloco de importação por planilha.
    assert_select "a[href=?]", guest_list_template_path(@list.token)
    assert_select "form[action=?]", guest_list_import_path(@list.token)
  end

  # --- Importação por planilha ---

  test "public template downloads the sample spreadsheet" do
    get guest_list_template_path(@list.token)
    assert_response :success
    assert_equal GuestTemplate::CONTENT_TYPE, @response.media_type
  end

  test "public import without a file redirects with an alert" do
    post guest_list_import_path(@list.token)
    assert_redirected_to guest_list_path(@list.token)
    assert_match(/Selecione um arquivo/, flash[:alert])
  end

  # --- Convidados: criar / atualizar / remover ---

  test "creating a guest adds a row to the event" do
    assert_difference -> { @event.guests.count }, 1 do
      post guest_list_guests_path(@list.token), as: :turbo_stream
    end
    assert_response :success
  end

  test "updating a guest saves the submitted attributes" do
    guest = @event.guests.create!

    patch guest_list_guest_path(@list.token, guest), params: {
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
    guest = @event.guests.create!

    assert_difference -> { @event.guests.count }, -1 do
      delete guest_list_guest_path(@list.token, guest), as: :turbo_stream
    end
  end

  # --- Finalizar trava a edição ---

  test "finalize locks the list against further writes" do
    patch finalize_guest_list_path(@list.token)
    assert @list.reload.submitted?

    assert_no_difference -> { @event.guests.count } do
      post guest_list_guests_path(@list.token), as: :turbo_stream
    end
    assert_response :forbidden
  end
end
