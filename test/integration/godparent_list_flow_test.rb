require "test_helper"

class GodparentListFlowTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(
      title: "Casamento Teste",
      event_type: "wedding",
      main_date: Date.current + 1.month,
      estimated_guests: 100
    )
  end

  # --- Wedding: lista já gerada na criação ---

  test "a godparent list is generated automatically for weddings" do
    assert @event.godparent_list.present?
    assert @event.godparent_list.token.present?
  end

  test "non-wedding events do not get a godparent list" do
    party = Event.create!(title: "Aniversário", event_type: "adult_birthday",
                          main_date: Date.current + 1.month, estimated_guests: 50)
    assert_nil party.godparent_list
  end

  # --- Admin: atualizar o link da lista (já existente) ---

  test "admin sets an expiry on the existing list without creating a new one" do
    assert_no_difference -> { GodparentList.count } do
      post event_godparent_list_path(@event), params: { godparent_list: { expires_at: 1.week.from_now } }
    end
    assert_redirected_to event_path(@event)
    list = @event.reload.godparent_list
    assert list.token.present?
    assert list.expires_at.present?
  end

  test "generating twice reuses the same list" do
    post event_godparent_list_path(@event), params: { godparent_list: {} }
    first = @event.reload.godparent_list
    post event_godparent_list_path(@event), params: { godparent_list: {} }
    assert_equal first.id, @event.reload.godparent_list.id
  end

  # --- Público: acesso por token ---

  test "public page renders for a valid token" do
    list = list_expiring(1.week.from_now)
    get godparent_list_path(list.token)
    assert_response :success
    assert_select "h1", text: @event.title
  end

  test "show creates a default blank pair when the list is empty" do
    list = list_expiring(1.week.from_now)
    assert_difference -> { @event.godparents.count }, 2 do
      get godparent_list_path(list.token)
    end
    assert_response :success
    assert_select "tr[id^=?]", "pair_"
  end

  test "show does not create extra pairs when one already exists" do
    list = list_expiring(1.week.from_now)
    list.add_pair!
    assert_no_difference -> { @event.godparents.count } do
      get godparent_list_path(list.token)
    end
  end

  test "show does not create a pair when the list is not editable" do
    list = list_expiring(1.day.ago)
    assert_no_difference -> { @event.godparents.count } do
      get godparent_list_path(list.token)
    end
  end

  test "invalid token returns not found" do
    get godparent_list_path("does-not-exist")
    assert_response :not_found
  end

  test "expired token returns gone" do
    list = list_expiring(1.day.ago)
    get godparent_list_path(list.token)
    assert_response :gone
  end

  # --- Pares: criar / atualizar / remover ---

  test "creating a pair builds two linked godparent guests" do
    list = list_expiring(1.week.from_now)
    assert_difference -> { @event.godparents.count }, 2 do
      post godparent_list_pairs_path(list.token), as: :turbo_stream
    end
    madrinha = @event.godparents.find_by(role: "madrinha")
    padrinho = @event.godparents.find_by(role: "padrinho")
    assert_equal padrinho.id, madrinha.pair_id
    assert_equal madrinha.id, padrinho.pair_id
    # O lado começa indefinido (a pessoa define depois).
    assert_nil madrinha.side
  end

  test "updating a pair saves member and pair attributes on both rows" do
    list = list_expiring(1.week.from_now)
    post godparent_list_pairs_path(list.token), as: :turbo_stream
    madrinha = @event.godparents.find_by(role: "madrinha")

    patch godparent_list_pair_path(list.token, madrinha), as: :turbo_stream, params: {
      pair: {
        side: "noivo",
        relationship: "casados",
        madrinha: { name: "Ana", phone_number: "11999990000", relation: "irmao" },
        padrinho: { name: "Pedro", phone_number: "11988880000", relation: "" }
      }
    }

    madrinha.reload
    padrinho = madrinha.pair
    assert_equal "Ana", madrinha.name
    assert_equal "irmao", madrinha.relation
    assert_equal "Pedro", padrinho.name
    assert_nil padrinho.relation
    # Lado e relação são atributos do par: gravados nas duas linhas.
    assert_equal "noivo", madrinha.side
    assert_equal "noivo", padrinho.side
    assert_equal "casados", madrinha.relationship
    assert_equal "casados", padrinho.relationship
  end

  test "destroying a pair removes both rows" do
    list = list_expiring(1.week.from_now)
    post godparent_list_pairs_path(list.token), as: :turbo_stream
    madrinha = @event.godparents.find_by(role: "madrinha")

    assert_difference -> { @event.godparents.count }, -2 do
      delete godparent_list_pair_path(list.token, madrinha), as: :turbo_stream
    end
  end

  # --- Salvar rascunho ---

  test "draft redirects with a success notice" do
    list = list_expiring(1.week.from_now)
    get draft_godparent_list_path(list.token)
    assert_redirected_to godparent_list_path(list.token)
    assert_match(/Rascunho salvo/, flash[:notice])
  end

  # --- Finalizar valida e trava a edição ---

  test "finalize is blocked when a pair is incomplete" do
    list = list_expiring(1.week.from_now)
    post godparent_list_pairs_path(list.token), as: :turbo_stream # par em branco

    patch finalize_godparent_list_path(list.token)
    assert_not list.reload.submitted?
    assert_match(/Preencha todos os campos/, flash[:alert])
  end

  test "finalize succeeds and locks when every pair is complete" do
    list = list_expiring(1.week.from_now)
    complete_pair!(list)

    patch finalize_godparent_list_path(list.token)
    assert list.reload.submitted?

    # Após finalizar, escrita é bloqueada.
    assert_no_difference -> { @event.godparents.count } do
      post godparent_list_pairs_path(list.token), as: :turbo_stream
    end
    assert_response :forbidden
  end

  private

  # Reuses the list auto-generated on wedding creation, applying an expiry.
  def list_expiring(expires_at)
    @event.godparent_list.tap { |list| list.update!(expires_at: expires_at) }
  end

  # Cria um par e preenche todos os campos.
  def complete_pair!(list)
    post godparent_list_pairs_path(list.token), as: :turbo_stream
    madrinha = list.event.godparents.where(role: "madrinha").order(:id).last
    patch godparent_list_pair_path(list.token, madrinha), as: :turbo_stream, params: {
      pair: {
        side: "noivo", relationship: "casados",
        madrinha: { name: "Ana", phone_number: "85999990000", relation: "irmao" },
        padrinho: { name: "Pedro", phone_number: "85988887777", relation: "amigo" }
      }
    }
    madrinha.reload
  end
end
