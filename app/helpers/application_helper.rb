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
  def whatsapp_link(value, css_class: "text-green-600 hover:text-green-700")
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

  PROVIDER_STATUS_LABELS = {
    "pendente" => "Pendente",
    "orcado" => "Orçado",
    "contratado" => "Contratado",
    "pago" => "Pago"
  }.freeze

  def translate_provider_status(status)
    PROVIDER_STATUS_LABELS[status.to_s] || status.to_s.humanize
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

  # Inline WhatsApp glyph as SVG (currentColor).
  def whatsapp_icon
    tag.svg(viewBox: "0 0 24 24", fill: "currentColor", class: "w-4 h-4", "aria-hidden": "true") do
      tag.path(d: "M.057 24l1.687-6.163a11.867 11.867 0 01-1.587-5.945C.16 5.335 5.495 0 12.05 0a11.82 11.82 0 018.413 3.488 11.82 11.82 0 013.48 8.414c-.003 6.557-5.338 11.892-11.893 11.892a11.9 11.9 0 01-5.688-1.448L.057 24zm6.597-3.807c1.676.995 3.276 1.591 5.392 1.592 5.448 0 9.886-4.434 9.889-9.885.002-5.462-4.415-9.89-9.881-9.892-5.452 0-9.887 4.434-9.889 9.884a9.86 9.86 0 001.51 5.26l-.999 3.648 3.728-.978a9.82 9.82 0 002.25 1.371zm5.413-6.4c-.074-.124-.272-.198-.57-.347-.297-.149-1.758-.868-2.031-.967-.272-.099-.47-.149-.669.149-.198.297-.768.967-.941 1.165-.173.198-.347.223-.644.074-.297-.149-1.255-.462-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.297-.347.446-.521.151-.172.2-.296.3-.495.099-.198.05-.372-.025-.521-.075-.148-.669-1.611-.916-2.206-.242-.579-.487-.501-.669-.51l-.57-.01c-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.872.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413z")
    end
  end
end
