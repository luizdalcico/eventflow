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

  test "generates a short token on create" do
    list = @event.family_member_list
    assert list.token.present?
    assert_equal PublicLinkList::TOKEN_LENGTH, list.token.length
    assert_equal list, FamilyMemberList.find_by(token: list.token)
  end

  test "uses token as the url param" do
    assert_equal @event.family_member_list.token, @event.family_member_list.to_param
  end

  test "is editable while in draft" do
    list = @event.family_member_list
    assert list.editable?
    assert_not list.submitted?
  end

  test "finalize! marks as submitted and locks editing" do
    list = @event.family_member_list
    list.finalize!
    assert list.submitted?
    assert list.submitted_at.present?
    assert_not list.editable?
  end
end
