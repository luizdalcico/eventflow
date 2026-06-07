require "test_helper"

class GodparentListFlowTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(
      title: "Casamento Teste",
      event_type: "wedding",
      main_date: Date.current + 1.month,
      estimated_guests: 100
    )
    @list = @event.godparent_list
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

  # --- Público: acesso por token ---

  test "public page renders for a valid token" do
    get godparent_list_path(@list.token)
    assert_response :success
    assert_select "h1", text: @event.title
  end

  test "show creates a default blank pair when the list is empty" do
    assert_difference -> { @event.godparents.count }, 2 do
      get godparent_list_path(@list.token)
    end
    assert_response :success
    assert_select "tr[id^=?]", "pair_"
  end

  test "show does not create extra pairs when one already exists" do
    @list.add_pair!
    assert_no_difference -> { @event.godparents.count } do
      get godparent_list_path(@list.token)
    end
  end

  test "show does not create a pair when the list is finalized" do
    @list.finalize!
    assert_no_difference -> { @event.godparents.count } do
      get godparent_list_path(@list.token)
    end
  end

  test "invalid token returns not found" do
    get godparent_list_path("nope")
    assert_response :not_found
  end

  # --- Pares: criar / atualizar / remover ---

  test "creating a pair builds two linked godparent guests" do
    list = @list
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
    list = @list
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
    list = @list
    post godparent_list_pairs_path(list.token), as: :turbo_stream
    madrinha = @event.godparents.find_by(role: "madrinha")

    assert_difference -> { @event.godparents.count }, -2 do
      delete godparent_list_pair_path(list.token, madrinha), as: :turbo_stream
    end
  end

  # --- Salvar rascunho ---

  test "draft redirects with a success notice" do
    list = @list
    get draft_godparent_list_path(list.token)
    assert_redirected_to godparent_list_path(list.token)
    assert_match(/Rascunho salvo/, flash[:notice])
  end

  # --- Finalizar valida e trava a edição ---

  test "finalize is blocked when a pair is incomplete" do
    list = @list
    post godparent_list_pairs_path(list.token), as: :turbo_stream # par em branco

    patch finalize_godparent_list_path(list.token)
    assert_not list.reload.submitted?
    assert_match(/Preencha todos os campos/, flash[:alert])
  end

  test "finalize succeeds and locks when every pair is complete" do
    list = @list
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
