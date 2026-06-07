require "test_helper"

class GuestTest < ActiveSupport::TestCase
  def setup
    @event = Event.create!(title: "Casamento", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
  end

  test "defaults guest_type to adult" do
    guest = @event.guests.create!(name: "João")
    assert_equal "adult", guest.guest_type
  end

  test "accepts adult and child guest_type" do
    assert @event.guests.create!(name: "Adulto", guest_type: "adult").persisted?
    assert @event.guests.create!(name: "Criança", guest_type: "child").persisted?
  end

  test "rejects an unknown guest_type" do
    guest = @event.guests.new(name: "Inválido", guest_type: "teen")
    assert_not guest.valid?
    assert guest.errors[:guest_type].present?
  end

  test "adults and children scopes filter by type" do
    adult = @event.guests.create!(name: "Adulto", guest_type: "adult")
    child = @event.guests.create!(name: "Criança", guest_type: "child")

    assert_includes @event.guests.adults, adult
    assert_not_includes @event.guests.adults, child
    assert_includes @event.guests.children, child
    assert_not_includes @event.guests.children, adult
  end

  test "total_adults and total_children sum party_size per type" do
    @event.guests.create!(name: "Casal", guest_type: "adult", party_size: 2)
    @event.guests.create!(name: "Solo", guest_type: "adult", party_size: 1)
    @event.guests.create!(name: "Filhos", guest_type: "child", party_size: 3)

    assert_equal 3, @event.guests.total_adults
    assert_equal 3, @event.guests.total_children
  end
end
