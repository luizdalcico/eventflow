class Guest < ApplicationRecord
  RSVP_STATUSES = %w[pending sent confirmed declined].freeze

  belongs_to :event

  validates :cpf, format: { with: /\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/, message: "deve estar no formato XXX.XXX.XXX-XX" }, allow_blank: true
  validates :rsvp_status, inclusion: { in: RSVP_STATUSES }
  validates :party_size, numericality: { greater_than_or_equal_to: 1 }

  before_validation :ensure_party_size

  scope :with_phone, -> { where.not(phone_number: [ nil, "" ]) }
  scope :rsvp_confirmed, -> { where(rsvp_status: "confirmed") }
  scope :rsvp_declined, -> { where(rsvp_status: "declined") }
  scope :rsvp_pending, -> { where(rsvp_status: %w[pending sent]) }

  # --- RSVP ---

  def rsvp_invitable?
    phone_number.present?
  end

  # Só envia (ou reenvia) para quem tem telefone e ainda está pendente —
  # evita mandar de novo para quem já recebeu ou já respondeu.
  def rsvp_sendable?
    rsvp_invitable? && rsvp_status == "pending"
  end

  def mark_rsvp_sent!(message_sid = nil)
    update!(rsvp_status: "sent", rsvp_sent_at: Time.current, rsvp_message_sid: message_sid)
  end

  def confirm_rsvp!
    update!(rsvp_status: "confirmed", rsvp_responded_at: Time.current)
  end

  def decline_rsvp!
    update!(rsvp_status: "declined", rsvp_responded_at: Time.current)
  end

  # Telefone em E.164 para o WhatsApp (assume Brasil/+55 quando sem DDI).
  def phone_e164
    digits = phone_number.to_s.gsub(/\D/, "")
    return nil if digits.blank?

    digits = "55#{digits}" unless digits.start_with?("55") && digits.length > 11
    "+#{digits}"
  end

  # Casa um telefone recebido (E.164/qualquer formato) com este convidado,
  # comparando os últimos 8 dígitos (ignora DDI/zeros/9 extra).
  def self.match_phone(raw)
    digits = raw.to_s.gsub(/\D/, "")
    return none if digits.length < 8

    tail = digits.last(8)
    where("regexp_replace(phone_number, '[^0-9]', '', 'g') LIKE ?", "%#{tail}")
  end

  # Soma de pessoas (considerando party_size) numa relação de convidados.
  def self.total_people
    sum(:party_size)
  end

  private

  def ensure_party_size
    self.party_size = 1 if party_size.blank? || party_size < 1
  end
end
