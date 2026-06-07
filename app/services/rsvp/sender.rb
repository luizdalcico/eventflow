module Rsvp
  # Envia o convite de RSVP por WhatsApp (Twilio Content template com botões).
  # Configuração por env: TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN,
  # TWILIO_WHATSAPP_FROM (ex.: "whatsapp:+14155238886"), TWILIO_RSVP_CONTENT_SID.
  class Sender
    def initialize(guest)
      @guest = guest
    end

    def call
      return false unless @guest.rsvp_invitable?
      return false unless configured?

      attrs = {
        to: "whatsapp:#{@guest.phone_e164}",
        content_sid: content_sid,
        content_variables: content_variables.to_json
      }
      # Em produção usa o Messaging Service; no sandbox, o número (from).
      if ENV["TWILIO_MESSAGING_SERVICE_SID"].present?
        attrs[:messaging_service_sid] = ENV["TWILIO_MESSAGING_SERVICE_SID"]
      else
        attrs[:from] = from
      end

      message = client.messages.create(**attrs)
      @guest.mark_rsvp_sent!(message.sid)
      true
    rescue Twilio::REST::RestError => e
      Rails.logger.error("RSVP send failed for guest #{@guest.id}: #{e.message}")
      false
    end

    def self.configured?
      ENV["TWILIO_ACCOUNT_SID"].present? && ENV["TWILIO_AUTH_TOKEN"].present? &&
        ENV["TWILIO_RSVP_CONTENT_SID"].present? &&
        (ENV["TWILIO_WHATSAPP_FROM"].present? || ENV["TWILIO_MESSAGING_SERVICE_SID"].present?)
    end

    private

    # Variáveis numeradas do Content template "rsvp":
    #   {{1}} = convidado, {{2}} = empresa, {{3}} = evento + data + horário.
    # (Poucas variáveis pra passar na validação da Meta de proporção texto/variável.)
    def content_variables
      event = @guest.event
      when_text = [event.main_date&.strftime("%d/%m/%Y"), event.start_time&.strftime("%Hh%M")].compact.join(" às ")
      details = [event.title.presence, when_text.presence].compact.join(" - ")

      {
        "1" => @guest.name.to_s,
        "2" => ENV["RSVP_COMPANY_NAME"].to_s,
        "3" => details
      }
    end

    def client
      @client ||= Twilio::REST::Client.new(ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"])
    end

    def configured?
      self.class.configured?
    end

    def from
      raw = ENV["TWILIO_WHATSAPP_FROM"].to_s
      raw.start_with?("whatsapp:") ? raw : "whatsapp:#{raw}"
    end

    def content_sid
      ENV["TWILIO_RSVP_CONTENT_SID"]
    end
  end
end
