require "test_helper"
require "minitest/mock"

module Rsvp
  class SenderTest < ActiveSupport::TestCase
    # Captura os atributos passados a client.messages.create sem chamar a Twilio.
    class FakeMessages
      attr_reader :captured
      def create(**attrs)
        @captured = attrs
        Struct.new(:sid).new("SM_FAKE")
      end
    end

    class FakeClient
      attr_reader :messages
      def initialize(messages) = @messages = messages
    end

    def setup
      @event = Event.create!(title: "Casamento Any e Luiz", event_type: "wedding",
                             main_date: Date.new(2026, 7, 31), start_time: "20:00",
                             estimated_guests: 100)
      @guest = @event.guests.create!(name: "Ticiana Oliveira", phone_number: "85999990000")
    end

    def with_twilio_env
      previous = ENV.to_h.slice("TWILIO_ACCOUNT_SID", "TWILIO_AUTH_TOKEN",
                                 "TWILIO_RSVP_CONTENT_SID", "TWILIO_MESSAGING_SERVICE_SID")
      ENV["TWILIO_ACCOUNT_SID"] = "AC123"
      ENV["TWILIO_AUTH_TOKEN"] = "tok"
      ENV["TWILIO_RSVP_CONTENT_SID"] = "HX123"
      ENV["TWILIO_MESSAGING_SERVICE_SID"] = "MG123"
      yield
    ensure
      %w[TWILIO_ACCOUNT_SID TWILIO_AUTH_TOKEN TWILIO_RSVP_CONTENT_SID TWILIO_MESSAGING_SERVICE_SID].each do |k|
        ENV[k] = previous[k]
      end
    end

    test "content variables map {{1}} guest, {{2}} event name, {{3}} date + time" do
      fake_messages = FakeMessages.new
      sender = Sender.new(@guest)

      with_twilio_env do
        sender.stub(:client, FakeClient.new(fake_messages)) do
          assert sender.call
        end
      end

      vars = JSON.parse(fake_messages.captured[:content_variables])
      assert_equal "Ticiana Oliveira", vars["1"]
      assert_equal "Casamento Any e Luiz", vars["2"]
      assert_equal "31/07/2026 às 20h00", vars["3"]
      assert_equal "MG123", fake_messages.captured[:messaging_service_sid]
      assert_equal "sent", @guest.reload.rsvp_status
    end
  end
end
