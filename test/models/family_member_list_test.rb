require "test_helper"

class FamilyMemberListTest < ActiveSupport::TestCase
  def setup
    @event = Event.create!(
      title: "Casamento Teste",
      event_type: "wedding",
      main_date: Date.current + 1.month,
      estimated_guests: 100
    )
  end

  test "generates a token on create" do
    list = family_member_list_with
    assert list.token.present?
    assert_equal list, FamilyMemberList.find_by(token: list.token)
  end

  test "uses token as the url param" do
    list = family_member_list_with
    assert_equal list.token, list.to_param
  end

  test "is editable when in draft and not expired" do
    list = family_member_list_with(expires_at: 1.day.from_now)
    assert list.editable?
    assert_not list.expired?
    assert_not list.submitted?
  end

  test "is not editable when expired" do
    list = family_member_list_with(expires_at: 1.day.ago)
    assert list.expired?
    assert_not list.editable?
  end

  test "never expires when expires_at is blank" do
    list = family_member_list_with(expires_at: nil)
    assert_not list.expired?
    assert list.editable?
  end

  test "finalize! marks as submitted and locks editing" do
    list = family_member_list_with(expires_at: 1.day.from_now)
    list.finalize!
    assert list.submitted?
    assert list.submitted_at.present?
    assert_not list.editable?
  end

  private

  # Reuses the list auto-generated on wedding creation, applying any attributes.
  def family_member_list_with(**attrs)
    @event.family_member_list.tap { |list| list.update!(attrs) if attrs.any? }
  end
end
