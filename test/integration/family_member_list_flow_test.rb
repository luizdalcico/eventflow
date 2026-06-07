require "test_helper"

class FamilyMemberListFlowTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(
      title: "Casamento Teste",
      event_type: "wedding",
      main_date: Date.current + 1.month,
      estimated_guests: 100
    )
  end

  # --- Auto-geração só para casamentos ---

  test "a family-member list is generated automatically for weddings" do
    assert @event.family_member_list.present?
    assert @event.family_member_list.token.present?
  end

  test "non-wedding events do not get a family-member list" do
    party = Event.create!(title: "Aniversário", event_type: "adult_birthday",
                          main_date: Date.current + 1.month, estimated_guests: 50)
    assert_nil party.family_member_list
  end

  # --- Admin: atualizar o link da lista ---

  test "admin sets an expiry on the existing list without creating a new one" do
    assert_no_difference -> { FamilyMemberList.count } do
      post event_family_member_list_path(@event), params: { family_member_list: { expires_at: 1.week.from_now } }
    end
    assert_redirected_to event_guests_path(@event)
    list = @event.reload.family_member_list
    assert list.expires_at.present?
  end

  test "admin create is blocked for non-weddings" do
    party = Event.create!(title: "Aniversário", event_type: "adult_birthday",
                          main_date: Date.current + 1.month, estimated_guests: 50)
    assert_no_difference -> { FamilyMemberList.count } do
      post event_family_member_list_path(party), params: { family_member_list: {} }
    end
    assert_redirected_to party
  end

  # --- Público: acesso por token ---

  test "public page renders for a valid token" do
    list = list_expiring(1.week.from_now)
    get family_member_list_path(list.token)
    assert_response :success
    assert_select "h1", text: @event.title
  end

  test "invalid token returns not found" do
    get family_member_list_path("does-not-exist")
    assert_response :not_found
  end

  test "expired token returns gone" do
    list = list_expiring(1.day.ago)
    get family_member_list_path(list.token)
    assert_response :gone
  end

  # --- Familiares: criar / atualizar / remover ---

  test "creating a family member adds a row to the event" do
    list = list_expiring(1.week.from_now)
    assert_difference -> { @event.family_members.count }, 1 do
      post family_member_list_members_path(list.token), params: {
        family_member: { name: "Maria", role: "mae_noiva" }
      }, as: :turbo_stream
    end
    assert_response :success
    assert_equal "mae_noiva", @event.family_members.last.role
  end

  test "creating a family member without a name re-renders the form" do
    list = list_expiring(1.week.from_now)
    assert_no_difference -> { @event.family_members.count } do
      post family_member_list_members_path(list.token), params: {
        family_member: { name: "", role: "outro" }
      }, as: :turbo_stream
    end
    assert_response :success
  end

  test "updating a family member saves the submitted attributes" do
    list = list_expiring(1.week.from_now)
    member = @event.family_members.create!(name: "Maria", position: 1)

    patch family_member_list_member_path(list.token, member), params: {
      family_member: { name: "Maria Souza", role: "avo_noiva", notes: "Cadeira de rodas" }
    }
    assert_response :no_content

    member.reload
    assert_equal "Maria Souza", member.name
    assert_equal "avo_noiva", member.role
    assert_equal "Cadeira de rodas", member.notes
  end

  test "destroying a family member removes the row" do
    list = list_expiring(1.week.from_now)
    member = @event.family_members.create!(name: "Maria", position: 1)

    assert_difference -> { @event.family_members.count }, -1 do
      delete family_member_list_member_path(list.token, member), as: :turbo_stream
    end
  end

  # --- Finalizar trava a edição ---

  test "finalize locks the list against further writes" do
    list = list_expiring(1.week.from_now)
    patch finalize_family_member_list_path(list.token)
    assert list.reload.submitted?

    assert_no_difference -> { @event.family_members.count } do
      post family_member_list_members_path(list.token), params: {
        family_member: { name: "Tarde", role: "outro" }
      }, as: :turbo_stream
    end
    assert_response :forbidden
  end

  private

  # Reuses the list auto-generated on wedding creation, applying an expiry.
  def list_expiring(expires_at)
    @event.family_member_list.tap { |list| list.update!(expires_at: expires_at) }
  end
end
