module Rsvp
  # Feature gate for actually dispatching RSVP messages. Stays off until the
  # WhatsApp Business / Twilio sender is approved; flip RSVP_SENDING_ENABLED to
  # enable real sending without touching code.
  def self.sending_enabled?
    ActiveModel::Type::Boolean.new.cast(ENV["RSVP_SENDING_ENABLED"])
  end
end
