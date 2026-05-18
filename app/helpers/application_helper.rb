module ApplicationHelper
  def translate_event_type(event_type)
    case event_type
    when 'wedding'
      'Casamento'
    when 'adult_birthday'
      'Aniversário Adulto'
    when 'children_birthday'
      'Aniversário Infantil'
    when 'corporate_event'
      'Evento Corporativo'
    else
      event_type.humanize
    end
  end

  def translate_provider_type(provider_type)
    case provider_type
    when 'photographer'
      'Fotógrafo'
    when 'buffet'
      'Buffet'
    when 'filming'
      'Filmagem'
    when 'cake'
      'Bolo'
    when 'sweets'
      'Doces'
    when 'chocolates'
      'Chocolates'
    when 'drinks'
      'Bebidas'
    when 'beer'
      'Cerveja'
    when 'light'
      'Iluminação'
    when 'decoration'
      'Decoração'
    when 'bouquet'
      'Buquê'
    when 'women_cloth'
      'Vestimenta Feminina'
    when 'men_cloth'
      'Vestimenta Masculina'
    when 'beauty_shop'
      'Salão de Beleza'
    when 'souvenir'
      'Lembrancinhas'
    when 'invitations'
      'Convites'
    when 'music_band'
      'Música/Banda'
    else
      provider_type.humanize
    end
  end
end
