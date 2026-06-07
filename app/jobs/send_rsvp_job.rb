class SendRsvpJob < ApplicationJob
  queue_as :default

  def perform(guest_id)
    guest = Guest.find_by(id: guest_id)
    return unless guest

    Rsvp::Sender.new(guest).call
  end
end
