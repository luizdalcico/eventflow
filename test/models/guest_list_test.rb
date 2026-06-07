require "test_helper"

class GuestListTest < ActiveSupport::TestCase
  def setup
    @event = Event.create!(
      title: "Festa Teste",
      event_type: "adult_birthday",
      main_date: Date.current + 1.month,
      estimated_guests: 50
    )
  end

  test "generates a short token on create" do
    list = @event.guest_list
    assert list.token.present?
    assert_equal PublicLinkList::TOKEN_LENGTH, list.token.length
    assert_equal list, GuestList.find_by(token: list.token)
  end

  test "uses token as the url param" do
    assert_equal @event.guest_list.token, @event.guest_list.to_param
  end

  test "is editable while in draft" do
    list = @event.guest_list
    assert list.editable?
    assert_not list.submitted?
  end

  test "finalize! marks as submitted and locks editing" do
    list = @event.guest_list
    list.finalize!
    assert list.submitted?
    assert list.submitted_at.present?
    assert_not list.editable?
  end
end
