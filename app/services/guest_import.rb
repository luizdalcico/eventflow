# Importa convidados de uma planilha (Excel .xlsx ou .csv) para um evento.
# Reconhece colunas por cabeçalho (sem acento/caixa): nome, quantidade de
# pessoas, telefone, tipo (adulto/criança), confirmação (SIM/NÃO) e observações.
class GuestImport
  Result = Struct.new(:imported, :skipped, :errors, keyword_init: true)

  HEADER_ALIASES = {
    name:         [ "nome", "nomes", "name", "convidado", "convidada" ],
    party_size:   [ "quant", "quantidade", "quantidade de convidados", "quantidade convidados", "qntd", "qntd pessoas", "pessoas", "qtd" ],
    phone_number: [ "telefone", "celular", "whatsapp", "fone", "phone", "tel" ],
    guest_type:   [ "tipo", "adulto/crianca", "adulto crianca", "adulto/criança", "categoria", "faixa" ],
    confirmation: [ "presenca", "confirmado", "confirmacao", "confirmacao de presenca", "std", "status", "retorno convite" ],
    notes:        [ "observacoes", "observacao", "obs", "observacoees", "comentarios" ]
  }.freeze

  EXTENSIONS = { ".xlsx" => :xlsx, ".csv" => :csv }.freeze
  CONFIRMED_WORDS = %w[sim yes confirmado s y].freeze
  DECLINED_WORDS  = %w[nao no n].freeze
  CHILD_WORDS     = %w[crianca infantil kid child].freeze

  def initialize(event, file)
    @event = event
    @file = file
  end

  def call
    ext = EXTENSIONS[File.extname(@file.original_filename.to_s).downcase]
    return error("Formato não suportado. Envie um arquivo .xlsx ou .csv.") unless ext

    sheet = Roo::Spreadsheet.open(@file.path, extension: ext).sheet(0)
    return error("Planilha vazia.") if sheet.last_row.to_i < 2

    cols = column_map(sheet.row(1))
    return error("Não encontrei uma coluna de nome (ex.: \"Nome\").") unless cols[:name]

    imported = 0
    skipped = 0
    errors = []

    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      attrs = build_attrs(row, cols)

      if attrs[:name].blank?
        skipped += 1
        next
      end

      guest = @event.guests.new(attrs)
      apply_confirmation(guest, cell(row, cols[:confirmation]))

      if guest.save
        imported += 1
      else
        errors << "Linha #{i}: #{guest.errors.full_messages.to_sentence}"
      end
    end

    Result.new(imported: imported, skipped: skipped, errors: errors)
  rescue StandardError => e
    error("Não foi possível ler o arquivo: #{e.message}")
  end

  private

  def error(message)
    Result.new(imported: 0, skipped: 0, errors: [ message ])
  end

  def column_map(header_row)
    normalized = header_row.map { |h| normalize(h) }
    HEADER_ALIASES.each_with_object({}) do |(field, aliases), map|
      idx = normalized.index { |h| aliases.include?(h) }
      map[field] = idx if idx
    end
  end

  def build_attrs(row, cols)
    {
      name: cell(row, cols[:name]),
      phone_number: cell(row, cols[:phone_number])&.gsub(/\D/, "").presence,
      party_size: cell(row, cols[:party_size])&.to_i,
      guest_type: guest_type_from(cell(row, cols[:guest_type])),
      notes: cell(row, cols[:notes])
    }.compact
  end

  # Traduz a coluna de tipo da planilha (Adulto/Criança) para o enum interno.
  # Sem valor reconhecido → nil, deixando o default "adult" do banco assumir.
  def guest_type_from(value)
    word = normalize(value)
    return nil if word.blank?

    CHILD_WORDS.include?(word) ? "child" : "adult"
  end

  # Pré-marca o RSVP a partir da coluna de confirmação da planilha (SIM/NÃO).
  def apply_confirmation(guest, value)
    word = normalize(value)
    return if word.blank?

    if CONFIRMED_WORDS.include?(word)
      guest.rsvp_status = "confirmed"
      guest.rsvp_responded_at = Time.current
    elsif DECLINED_WORDS.include?(word)
      guest.rsvp_status = "declined"
      guest.rsvp_responded_at = Time.current
    end
  end

  def cell(row, idx)
    return nil if idx.nil?

    value = row[idx]
    value = value.to_s.strip if value
    value.presence
  end

  def normalize(value)
    ActiveSupport::Inflector.transliterate(value.to_s).downcase.strip
  end
end
