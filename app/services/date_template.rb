# Catálogo de marcos de data por tipo de evento. Semeia a tela "Outras datas"
# (event_dates) com datas editáveis, calculadas a partir da data principal.
#
# Cada item tem uma descrição e:
#   - offset_days: deslocamento relativo à data principal (negativo = antes); ou
#   - contract: true — data definida em contrato; semeada com a data principal
#     como placeholder, para o usuário ajustar inline depois (event_dates.date
#     é NOT NULL, então não existe data "em aberto").
class DateTemplate
  # Catálogo por event_type. Offsets em dias corridos relativos à main_date.
  CATALOG = {
    "wedding" => [
      { description: "Reunião com celebrante / reserva da igreja", offset_days: -150 },
      { description: "Curso de noivos", offset_days: -90 },
      { description: "Ensaio externo (pré-wedding)", offset_days: -60 },
      { description: "Entrega/envio dos convites", offset_days: -45 },
      { description: "Degustação do buffet", offset_days: -30 },
      { description: "Prova de cabelo e maquiagem", offset_days: -15 },
      { description: "Prova do vestido/traje", offset_days: -15 },
      { description: "Prazo final da lista de convidados", offset_days: -10 },
      { description: "Briefing geral com a equipe", offset_days: -5 },
      { description: "Pagamento final (conforme contrato)", contract: true }
    ].freeze,
    "quinze_anos" => [
      { description: "Entrega/envio dos convites", offset_days: -45 },
      { description: "Ensaio fotográfico", offset_days: -60 },
      { description: "Degustação do buffet", offset_days: -30 },
      { description: "Prova de roupa e maquiagem", offset_days: -15 },
      { description: "Prazo final da lista de convidados", offset_days: -10 },
      { description: "Briefing geral com a equipe", offset_days: -5 },
      { description: "Pagamento final (conforme contrato)", contract: true }
    ].freeze,
    "adult_birthday" => [
      { description: "Entrega/envio dos convites", offset_days: -45 },
      { description: "Ensaio fotográfico", offset_days: -60 },
      { description: "Degustação do buffet", offset_days: -30 },
      { description: "Prova de roupa e maquiagem", offset_days: -15 },
      { description: "Prazo final da lista de convidados", offset_days: -10 },
      { description: "Briefing geral com a equipe", offset_days: -5 },
      { description: "Pagamento final (conforme contrato)", contract: true }
    ].freeze,
    "children_birthday" => [
      { description: "Entrega/envio dos convites", offset_days: -45 },
      { description: "Ensaio fotográfico", offset_days: -60 },
      { description: "Degustação do buffet", offset_days: -30 },
      { description: "Prova de roupa e maquiagem", offset_days: -15 },
      { description: "Prazo final da lista de convidados", offset_days: -10 },
      { description: "Briefing geral com a equipe", offset_days: -5 },
      { description: "Pagamento final (conforme contrato)", contract: true }
    ].freeze,
    "corporate_event" => [
      { description: "Reunião de alinhamento", offset_days: -45 },
      { description: "Aprovação do roteiro/script", offset_days: -20 },
      { description: "Montagem", offset_days: -1 },
      { description: "Pagamento final (conforme contrato)", contract: true }
    ].freeze
  }.freeze

  # Itens do catálogo para um tipo de evento (vazio se não houver template).
  def self.items_for(event_type)
    CATALOG[event_type.to_s] || []
  end

  # Há template disponível para o tipo de evento?
  def self.available_for?(event_type)
    items_for(event_type).any?
  end

  # Semeia as datas do template no evento. Idempotente: só cria descrições que
  # ainda não existem, então reaplicar (ou aplicar após edições) nunca duplica.
  # Retorna os EventDate criados.
  def self.apply(event)
    # main_date é validada como presente em Event, mas guardamos mesmo assim:
    # sem ela não há âncora para resolver os offsets.
    return [] if event.main_date.blank?

    existing = event.event_dates.pluck(:description)
    items = items_for(event.event_type).reject { |item| existing.include?(item[:description]) }

    EventDate.transaction do
      items.map do |item|
        event.event_dates.create!(description: item[:description], date: resolve_date(event, item))
      end
    end
  end

  # Resolve a data concreta de um item: offset relativo à data principal, ou a
  # própria data principal como placeholder para itens definidos em contrato.
  def self.resolve_date(event, item)
    return event.main_date if item[:contract]

    event.main_date + item[:offset_days].days
  end
  private_class_method :resolve_date
end
