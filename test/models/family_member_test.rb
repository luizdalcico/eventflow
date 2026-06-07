require "test_helper"

class FamilyMemberTest < ActiveSupport::TestCase
  def setup
    @event = Event.create!(
      title: "Casamento Teste",
      event_type: "wedding",
      main_date: Date.current + 1.month,
      estimated_guests: 100
    )
  end

  test "is valid with a name" do
    member = @event.family_members.new(name: "Maria")
    assert member.valid?
  end

  test "requires a name" do
    member = @event.family_members.new(name: "")
    assert_not member.valid?
    assert_includes member.errors.attribute_names, :name
  end

  test "accepts a blank role" do
    member = @event.family_members.new(name: "Maria", role: "")
    assert member.valid?
  end

  test "rejects a role outside the allowed list" do
    member = @event.family_members.new(name: "Maria", role: "invalido")
    assert_not member.valid?
    assert_includes member.errors.attribute_names, :role
  end

  test "ordered scope sorts by persisted position" do
    second = @event.family_members.create!(name: "Segundo", position: 2)
    first = @event.family_members.create!(name: "Primeiro", position: 1)
    assert_equal [ first.id, second.id ], @event.family_members.ordered.pluck(:id)
  end
end
