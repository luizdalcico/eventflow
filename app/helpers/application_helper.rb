module ApplicationHelper
  # Formata um telefone (dígitos) para exibição: (DD) 9XXXX-XXXX.
  def format_phone(value)
    d = value.to_s.gsub(/\D/, "")
    d = d.sub(/\A55/, "") if d.length > 11
    case d.length
    when 11 then "(#{d[0, 2]}) #{d[2, 5]}-#{d[7, 4]}"
    when 10 then "(#{d[0, 2]}) #{d[2, 4]}-#{d[6, 4]}"
    else value.presence || "—"
    end
  end

  # Builds a WhatsApp conversation URL (wa.me) from a phone number.
  # Normalizes to digits and assumes Brazil/+55 when no country code is present; nil when blank.
  def whatsapp_url(value)
    digits = value.to_s.gsub(/\D/, "")
    return nil if digits.blank?

    digits = "55#{digits}" unless digits.start_with?("55") && digits.length > 11
    "https://wa.me/#{digits}"
  end

  # Renders a WhatsApp icon that opens the conversation in a new tab.
  # Returns nil when there is no usable phone number.
  def whatsapp_link(value, css_class: "hover:opacity-80")
    url = whatsapp_url(value)
    return nil if url.nil?

    link_to url, target: "_blank", rel: "noopener", title: "Conversar no WhatsApp",
            "aria-label": "Conversar no WhatsApp", class: "inline-flex align-middle #{css_class}" do
      whatsapp_icon
    end
  end

  EVENT_TYPE_LABELS = {
    "wedding" => "Casamento",
    "quinze_anos" => "Quinze anos",
    "formatura" => "Formatura",
    "bodas" => "Bodas",
    "adult_birthday" => "Aniversário Adulto",
    "children_birthday" => "Aniversário Infantil",
    "corporate_event" => "Evento Corporativo"
  }.freeze

  def translate_event_type(event_type)
    EVENT_TYPE_LABELS[event_type] || event_type.to_s.humanize
  end

  # Renders the reusable breadcrumb trail. Each crumb is a [label, path] pair;
  # the final crumb is the current page and is rendered as plain text.
  def breadcrumbs(*crumbs)
    render "shared/breadcrumbs", crumbs: crumbs
  end

  # Short label for an event used across breadcrumb trails: its title, falling
  # back to the humanized event type when the title is blank.
  def event_crumb_label(event)
    event.title.presence || translate_event_type(event.event_type)
  end

  PROVIDER_STATUS_LABELS = {
    "pendente" => "Pendente",
    "orcado" => "Orçado",
    "contratado" => "Contratado",
    "pago" => "Pago"
  }.freeze

  def translate_provider_status(status)
    PROVIDER_STATUS_LABELS[status.to_s] || status.to_s.humanize
  end

  PAYMENT_METHOD_LABELS = {
    "pix" => "PIX",
    "dinheiro" => "Dinheiro",
    "cartao" => "Cartão",
    "transferencia" => "Transferência",
    "cheque" => "Cheque",
    "boleto" => "Boleto"
  }.freeze

  def translate_payment_method(method)
    PAYMENT_METHOD_LABELS[method.to_s] || method.to_s.humanize
  end

  PENDENCY_STATUS_LABELS = {
    "pendente" => "Pendente",
    "em_andamento" => "Em andamento",
    "concluida" => "Concluída"
  }.freeze

  def translate_pendency_status(status)
    PENDENCY_STATUS_LABELS[status.to_s] || status.to_s.humanize
  end

  # [label, value] pairs for the pendency status select.
  def pendency_status_options
    Pendency::STATUSES.map { |status| [ translate_pendency_status(status), status ] }
  end

  # [label, id] pairs of the event's providers for the pendency provider select.
  def event_providers_for_select(event)
    event.event_providers.includes(:provider).map do |ep|
      [ "#{translate_provider_type(ep.provider.provider_type)} — #{ep.provider.name}", ep.id ]
    end
  end

  # Format a numeric amount as Brazilian currency: R$ 1.234,56.
  def format_brl(amount)
    integer, decimals = format("%.2f", amount.to_f).split(".")
    grouped = integer.reverse.gsub(/(\d{3})(?=\d)/, '\1.').reverse
    "R$ #{grouped},#{decimals}"
  end

  def translate_provider_type(provider_type)
    case provider_type
    when "photographer"
      "Fotógrafo"
    when "buffet"
      "Buffet"
    when "filming"
      "Filmagem"
    when "cake"
      "Bolo"
    when "sweets"
      "Doces"
    when "chocolates"
      "Chocolates"
    when "drinks"
      "Bebidas"
    when "beer"
      "Cerveja"
    when "light"
      "Iluminação"
    when "decoration"
      "Decoração"
    when "bouquet"
      "Buquê"
    when "women_cloth"
      "Vestimenta Feminina"
    when "men_cloth"
      "Vestimenta Masculina"
    when "beauty_shop"
      "Salão de Beleza"
    when "souvenir"
      "Lembrancinhas"
    when "invitations"
      "Convites"
    when "music_band"
      "Música/Banda"
    else
      provider_type.humanize
    end
  end

  private

  # Inline WhatsApp logo: green bubble with the white handset cut out.
  def whatsapp_icon
    tag.svg(viewBox: "0 0 24 24", class: "w-4 h-4", "aria-hidden": "true") do
      safe_join([
        tag.path(fill: "#25D366",
          d: "M12.04 2C6.58 2 2.13 6.45 2.13 11.91c0 1.75.46 3.45 1.32 4.95L2 22l5.25-1.38c1.45.79 3.08 1.21 4.79 1.21h.01c5.46 0 9.91-4.45 9.91-9.91C21.95 6.45 17.5 2 12.04 2z"),
        tag.path(fill: "#FFF",
          d: "M9.53 7.33c-.18-.41-.37-.42-.55-.43l-.47-.01c-.16 0-.43.06-.66.31-.23.25-.86.84-.86 2.06 0 1.21.88 2.38 1 2.55.12.16 1.71 2.74 4.23 3.73 2.09.82 2.52.66 2.97.62.45-.04 1.46-.6 1.67-1.18.21-.58.21-1.07.15-1.18-.06-.1-.23-.16-.47-.29-.25-.12-1.46-.72-1.69-.8-.23-.08-.39-.12-.55.12-.16.25-.64.8-.78.97-.14.16-.29.18-.53.06-.25-.12-1.04-.38-1.98-1.22-.73-.65-1.23-1.46-1.37-1.71-.14-.25-.01-.38.11-.5.11-.11.25-.29.37-.43.12-.14.16-.25.25-.41.08-.16.04-.31-.02-.43-.06-.12-.54-1.35-.76-1.84z")
      ])
    end
  end
end
