require "test_helper"

class FamilyMembersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(title: "Casamento", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
  end

  test "create adds a family member and redirects to the guests page" do
    assert_difference -> { @event.family_members.count }, 1 do
      post event_family_members_path(@event), params: { family_member: { name: "Maria", role: "mae_noiva" } }
    end
    assert_redirected_to event_guests_path(@event)
  end

  test "destroy removes a family member and redirects to the guests page" do
    member = @event.family_members.create!(name: "José", role: "pai_noivo", position: 1)

    assert_difference -> { @event.family_members.count }, -1 do
      delete event_family_member_path(@event, member)
    end
    assert_redirected_to event_guests_path(@event)
  end
end
