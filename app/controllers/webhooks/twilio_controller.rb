module Webhooks
  # Recebe as respostas de RSVP do WhatsApp (Twilio inbound).
  # Configure no Twilio (sandbox ou número): "When a message comes in" →
  # POST https://<host>/webhooks/twilio/whatsapp
  class TwilioController < ApplicationController
    skip_forgery_protection

    def whatsapp
      return head(:forbidden) unless valid_signature?

      guest = find_guest(params[:From])
      reply =
        if guest.nil?
          nil
        elsif positive?(answer)
          guest.confirm_rsvp!
          "Presença confirmada! 🎉 Obrigado."
        elsif negative?(answer)
          guest.decline_rsvp!
          "Tudo bem, registramos que você não poderá ir. Obrigado por avisar!"
        end

      render xml: twiml(reply)
    end

    private

    # Texto da resposta: prioriza o payload do botão, cai para o corpo da mensagem.
    def answer
      (params[:ButtonPayload].presence || params[:ButtonText].presence || params[:Body]).to_s.downcase
    end

    def positive?(text)
      text.include?("yes") || text.include?("sim") || text.include?("confirm")
    end

    def negative?(text)
      text.include?("rsvp_no") || text.include?("nao") || text.include?("não") || text.include?("recus") || text.include?("não poderei")
    end

    def find_guest(from)
      Guest.match_phone(from).order(rsvp_sent_at: :desc, id: :desc).first
    end

    def twiml(message)
      body = message ? "<Message>#{message}</Message>" : ""
      %(<?xml version="1.0" encoding="UTF-8"?><Response>#{body}</Response>)
    end

    def valid_signature?
      return true if ENV["TWILIO_SKIP_SIGNATURE"] == "true"

      token = ENV["TWILIO_AUTH_TOKEN"]
      return true if token.blank? # sem token configurado (dev) — não bloqueia

      validator = Twilio::Security::RequestValidator.new(token)
      validator.validate(request.original_url, request.request_parameters, request.headers["X-Twilio-Signature"])
    end
  end
end
