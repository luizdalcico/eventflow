# Catálogo de marcos de data por tipo de evento. Semeia a tela "Outras datas"
# (event_dates) com os marcos típicos do tipo, sem datas: o usuário preenche a
# data de cada um depois, inline.
class DateTemplate
  # Marcos (descrições) por event_type, na ordem cronológica usual.
  CATALOG = {
    "wedding" => [
      "Reunião com celebrante / reserva da igreja",
      "Curso de noivos",
      "Ensaio externo (pré-wedding)",
      "Entrega/envio dos convites",
      "Degustação do buffet",
      "Prova de cabelo e maquiagem",
      "Prova do vestido/traje",
      "Prazo final da lista de convidados",
      "Briefing geral com a equipe",
      "Pagamento final (conforme contrato)"
    ].freeze,
    "quinze_anos" => [
      "Ensaio fotográfico",
      "Entrega/envio dos convites",
      "Degustação do buffet",
      "Prova de roupa e maquiagem",
      "Prazo final da lista de convidados",
      "Briefing geral com a equipe",
      "Pagamento final (conforme contrato)"
    ].freeze,
    "adult_birthday" => [
      "Ensaio fotográfico",
      "Entrega/envio dos convites",
      "Degustação do buffet",
      "Prova de roupa e maquiagem",
      "Prazo final da lista de convidados",
      "Briefing geral com a equipe",
      "Pagamento final (conforme contrato)"
    ].freeze,
    "children_birthday" => [
      "Ensaio fotográfico",
      "Entrega/envio dos convites",
      "Degustação do buffet",
      "Prova de roupa e maquiagem",
      "Prazo final da lista de convidados",
      "Briefing geral com a equipe",
      "Pagamento final (conforme contrato)"
    ].freeze,
    "corporate_event" => [
      "Reunião de alinhamento",
      "Aprovação do roteiro/script",
      "Montagem",
      "Pagamento final (conforme contrato)"
    ].freeze
  }.freeze

  # Descrições do catálogo para um tipo de evento (vazio se não houver template).
  def self.items_for(event_type)
    CATALOG[event_type.to_s] || []
  end

  # Há template disponível para o tipo de evento?
  def self.available_for?(event_type)
    items_for(event_type).any?
  end

  # Semeia os marcos do template no evento, sem data (para preencher depois).
  # Idempotente: só cria descrições que ainda não existem, então reaplicar (ou
  # aplicar após edições) nunca duplica. Retorna os EventDate criados.
  def self.apply(event)
    existing = event.event_dates.pluck(:description)
    descriptions = items_for(event.event_type) - existing

    EventDate.transaction do
      descriptions.map { |description| event.event_dates.create!(description: description) }
    end
  end
end
