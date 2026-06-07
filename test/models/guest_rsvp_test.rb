require "test_helper"

class GuestRsvpTest < ActiveSupport::TestCase
  def setup
    @event = Event.create!(title: "Casamento", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
  end

  test "phone_e164 prefixes +55 for Brazilian numbers" do
    guest = @event.guests.create!(name: "João", phone_number: "85999990000")
    assert_equal "+5585999990000", guest.phone_e164
  end

  test "phone_e164 does not double the country code" do
    guest = @event.guests.create!(name: "João", phone_number: "5585999990000")
    assert_equal "+5585999990000", guest.phone_e164
  end

  test "match_phone finds the guest by the last 8 digits" do
    guest = @event.guests.create!(name: "João", phone_number: "85999990000")
    assert_includes Guest.match_phone("whatsapp:+5585999990000"), guest
    assert_includes Guest.match_phone("99990000"), guest
    assert_not_includes Guest.match_phone("12345678"), guest
  end

  test "confirm and decline update status and timestamp" do
    guest = @event.guests.create!(name: "João", phone_number: "85999990000")
    guest.confirm_rsvp!
    assert_equal "confirmed", guest.rsvp_status
    assert guest.rsvp_responded_at.present?

    guest.decline_rsvp!
    assert_equal "declined", guest.rsvp_status
  end

  test "rsvp_invitable? requires a phone" do
    assert @event.guests.create!(name: "Com fone", phone_number: "85999990000").rsvp_invitable?
    assert_not @event.guests.create!(name: "Sem fone").rsvp_invitable?
  end
end
