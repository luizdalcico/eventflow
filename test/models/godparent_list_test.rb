require "test_helper"

class GodparentListTest < ActiveSupport::TestCase
  def setup
    @event = Event.create!(
      title: "Casamento Teste",
      event_type: "wedding",
      main_date: Date.current + 1.month,
      estimated_guests: 100
    )
  end

  test "generates a short token on create" do
    list = godparent_list_with
    assert list.token.present?
    assert_equal PublicLinkList::TOKEN_LENGTH, list.token.length
    assert_equal list, GodparentList.find_by(token: list.token)
  end

  test "uses token as the url param" do
    list = godparent_list_with
    assert_equal list.token, list.to_param
  end

  test "is editable while in draft" do
    list = godparent_list_with
    assert list.editable?
    assert_not list.submitted?
  end

  test "finalize! marks as submitted and locks editing" do
    list = godparent_list_with
    list.finalize!
    assert list.submitted?
    assert list.submitted_at.present?
    assert_not list.editable?
  end

  test "pairs_count counts linked godparent pairs" do
    list = godparent_list_with
    madrinha = @event.godparents.create!(role: "madrinha", name: "Ana")
    padrinho = @event.godparents.create!(role: "padrinho", name: "Pedro")
    madrinha.update!(pair_id: padrinho.id)
    padrinho.update!(pair_id: madrinha.id)

    assert_equal 1, list.pairs_count
  end

  private

  # Reuses the list auto-generated on wedding creation, applying any attributes.
  def godparent_list_with(**attrs)
    @event.godparent_list.tap { |list| list.update!(attrs) if attrs.any? }
  end
end
