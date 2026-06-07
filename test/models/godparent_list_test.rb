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

  test "generates a token on create" do
    list = @event.create_godparent_list!
    assert list.token.present?
    assert_equal list, GodparentList.find_by(token: list.token)
  end

  test "uses token as the url param" do
    list = @event.create_godparent_list!
    assert_equal list.token, list.to_param
  end

  test "is editable when in draft and not expired" do
    list = @event.create_godparent_list!(expires_at: 1.day.from_now)
    assert list.editable?
    assert_not list.expired?
    assert_not list.submitted?
  end

  test "is not editable when expired" do
    list = @event.create_godparent_list!(expires_at: 1.day.ago)
    assert list.expired?
    assert_not list.editable?
  end

  test "never expires when expires_at is blank" do
    list = @event.create_godparent_list!(expires_at: nil)
    assert_not list.expired?
    assert list.editable?
  end

  test "finalize! marks as submitted and locks editing" do
    list = @event.create_godparent_list!(expires_at: 1.day.from_now)
    list.finalize!
    assert list.submitted?
    assert list.submitted_at.present?
    assert_not list.editable?
  end

  test "pairs_count counts linked godparent pairs" do
    list = @event.create_godparent_list!
    madrinha = @event.godparents.create!(role: "madrinha", name: "Ana")
    padrinho = @event.godparents.create!(role: "padrinho", name: "Pedro")
    madrinha.update!(pair_id: padrinho.id)
    padrinho.update!(pair_id: madrinha.id)

    assert_equal 1, list.pairs_count
  end
end
