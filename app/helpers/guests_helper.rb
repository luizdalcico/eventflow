module GuestsHelper
  GUEST_TYPE_LABELS = { "adult" => "Adulto", "child" => "Criança" }.freeze
  RSVP_LABELS = {
    "pending"   => "Pendente",
    "sent"      => "Enviado",
    "confirmed" => "Confirmado",
    "declined"  => "Recusou"
  }.freeze

  def guest_type_label(guest_type)
    GUEST_TYPE_LABELS.fetch(guest_type, guest_type)
  end

  def rsvp_label(rsvp_status)
    RSVP_LABELS.fetch(rsvp_status, rsvp_status)
  end
end
