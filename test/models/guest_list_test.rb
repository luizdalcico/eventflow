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

  test "generates a token on create" do
    list = guest_list_with
    assert list.token.present?
    assert_equal list, GuestList.find_by(token: list.token)
  end

  test "uses token as the url param" do
    list = guest_list_with
    assert_equal list.token, list.to_param
  end

  test "is editable when in draft and not expired" do
    list = guest_list_with(expires_at: 1.day.from_now)
    assert list.editable?
    assert_not list.expired?
    assert_not list.submitted?
  end

  test "is not editable when expired" do
    list = guest_list_with(expires_at: 1.day.ago)
    assert list.expired?
    assert_not list.editable?
  end

  test "never expires when expires_at is blank" do
    list = guest_list_with(expires_at: nil)
    assert_not list.expired?
    assert list.editable?
  end

  test "finalize! marks as submitted and locks editing" do
    list = guest_list_with(expires_at: 1.day.from_now)
    list.finalize!
    assert list.submitted?
    assert list.submitted_at.present?
    assert_not list.editable?
  end

  private

  # Reuses the list auto-generated on event creation, applying any attributes.
  def guest_list_with(**attrs)
    @event.guest_list.tap { |list| list.update!(attrs) if attrs.any? }
  end
end
