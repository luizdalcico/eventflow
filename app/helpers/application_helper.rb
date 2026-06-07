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
end
