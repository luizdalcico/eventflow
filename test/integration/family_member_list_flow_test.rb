require "test_helper"

class FamilyMemberListFlowTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(
      title: "Casamento Teste",
      event_type: "wedding",
      main_date: Date.current + 1.month,
      estimated_guests: 100
    )
    @list = @event.family_member_list
  end

  # --- Auto-geração só para casamentos ---

  test "a family-member list is generated automatically for weddings" do
    assert @list.present?
    assert @list.token.present?
  end

  test "non-wedding events do not get a family-member list" do
    party = Event.create!(title: "Aniversário", event_type: "adult_birthday",
                          main_date: Date.current + 1.month, estimated_guests: 50)
    assert_nil party.family_member_list
  end

  # --- Público: acesso por token ---

  test "public page renders for a valid token" do
    get family_member_list_path(@list.token)
    assert_response :success
    assert_select "h1", text: @event.title
  end

  test "invalid token returns not found" do
    get family_member_list_path("nope")
    assert_response :not_found
  end

  # --- Familiares: criar / atualizar / remover ---

  test "creating a family member adds a row to the event" do
    assert_difference -> { @event.family_members.count }, 1 do
      post family_member_list_members_path(@list.token), params: {
        family_member: { name: "Maria", role: "mae_noiva" }
      }, as: :turbo_stream
    end
    assert_response :success
    assert_equal "mae_noiva", @event.family_members.last.role
  end

  test "creating a family member without a name re-renders the form" do
    assert_no_difference -> { @event.family_members.count } do
      post family_member_list_members_path(@list.token), params: {
        family_member: { name: "", role: "outro" }
      }, as: :turbo_stream
    end
    assert_response :success
  end

  test "updating a family member saves the submitted attributes" do
    member = @event.family_members.create!(name: "Maria", position: 1)

    patch family_member_list_member_path(@list.token, member), params: {
      family_member: { name: "Maria Souza", role: "avo_noiva", notes: "Cadeira de rodas" }
    }
    assert_response :no_content

    member.reload
    assert_equal "Maria Souza", member.name
    assert_equal "avo_noiva", member.role
    assert_equal "Cadeira de rodas", member.notes
  end

  test "destroying a family member removes the row" do
    member = @event.family_members.create!(name: "Maria", position: 1)

    assert_difference -> { @event.family_members.count }, -1 do
      delete family_member_list_member_path(@list.token, member), as: :turbo_stream
    end
  end

  # --- Finalizar trava a edição ---

  test "finalize locks the list against further writes" do
    patch finalize_family_member_list_path(@list.token)
    assert @list.reload.submitted?

    assert_no_difference -> { @event.family_members.count } do
      post family_member_list_members_path(@list.token), params: {
        family_member: { name: "Tarde", role: "outro" }
      }, as: :turbo_stream
    end
    assert_response :forbidden
  end
end
