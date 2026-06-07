class TemplateService
  extend ApplicationHelper

  def self.generate_event_report(event, format = :pdf)
    case format.to_sym
    when :pdf
      generate_pdf_report(event)
    when :xlsx
      generate_xlsx_cost_sheet(event)
    else
      raise ArgumentError, "Formato não suportado: #{format}"
    end
  end

  # Renders the service contract (clause template merged with the event's
  # contract fields + contratante data) as a PDF byte string.
  def self.generate_contract(event, format = :pdf)
    case format.to_sym
    when :pdf
      generate_contract_pdf(event)
    else
      raise ArgumentError, "Formato não suportado: #{format}"
    end
  end

  private

  def self.generate_pdf_report(event)
    Prawn::Document.new do |pdf|
      # Header
      pdf.font_size 24
      pdf.text "Cerimonial.app - Relatório do Evento", align: :center, style: :bold
      pdf.move_down 20

      # Event basic info
      pdf.font_size 16
      pdf.text "Informações Básicas", style: :bold
      pdf.move_down 10

      pdf.font_size 12
      event_info = [
        [ "Tipo:", translate_event_type(event.event_type) ],
        [ "Responsável:", event.event_owners.first&.name || "Não definido" ],
        [ "Data Principal:", event.main_date.strftime("%d/%m/%Y") ],
        [ "Horário:", "#{event.start_time&.strftime('%H:%M')} - #{event.end_time&.strftime('%H:%M')}" ],
        [ "Local:", event.place || "Não definido" ],
        [ "Endereço:", event.address || "Não definido" ],
        [ "Convidados Estimados:", event.estimated_guests.to_s ],
        [ "Horas Extras:", event.extra_hours&.to_s || "0" ]
      ]

      pdf.table(event_info, width: pdf.bounds.width, cell_style: { borders: [] }) do
        column(0).style(font_style: :bold, width: 150)
      end

      pdf.move_down 20

      # Event Owners
      if event.event_owners.any?
        pdf.font_size 16
        pdf.text "Responsáveis pelo Evento", style: :bold
        pdf.move_down 10

        pdf.font_size 12
        owners_data = [ [ "Nome", "Função", "Telefone", "CPF" ] ]
        event.event_owners.each do |owner|
          owners_data << [
            owner.name,
            owner.role || "-",
            owner.phone_number,
            owner.cpf || "-"
          ]
        end

        pdf.table(owners_data, header: true, width: pdf.bounds.width) do
          row(0).font_style = :bold
          self.header = true
        end

        pdf.move_down 20
      end

      # Cortejo (momentos da cerimônia, em ordem)
      steps = event.procession_steps.ordered
      if steps.any?
        pdf.font_size 16
        pdf.text "Cortejo", style: :bold
        pdf.move_down 10

        pdf.font_size 12
        steps_data = [ [ "Ordem", "Momento", "Tipo" ] ]
        steps.each_with_index do |step, index|
          steps_data << [
            (index + 1).to_s,
            step.description,
            step.kind.present? ? I18n.t("procession_step.kinds.#{step.kind}") : "-"
          ]
        end

        pdf.table(steps_data, header: true, width: pdf.bounds.width) do
          row(0).font_style = :bold
          self.header = true
        end

        pdf.move_down 20
      end

      # Padrinhos & Familiares
      godparents = event.godparents.ordered
      family = event.family_members.ordered
      if godparents.any? || family.any?
        pdf.font_size 16
        pdf.text "Padrinhos & Familiares", style: :bold
        pdf.move_down 10

        pdf.font_size 12
        people_data = [ [ "Nome", "Papel" ] ]
        godparents.each do |godparent|
          people_data << [ godparent.name.presence || "-", godparent.role.presence || "-" ]
        end
        family.each do |member|
          role = member.role.present? ? I18n.t("family_member.roles.#{member.role}") : "-"
          people_data << [ member.name, role ]
        end

        pdf.table(people_data, header: true, width: pdf.bounds.width) do
          row(0).font_style = :bold
          self.header = true
        end

        pdf.move_down 20
      end

      # Guests Summary
      pdf.font_size 16
      pdf.text "Resumo de Convidados", style: :bold
      pdf.move_down 10

      pdf.font_size 12
      guests_summary = [
        [ "Total de Convidados:", event.guests.count.to_s ],
        [ "Padrinhos:", event.godparents.count.to_s ]
      ]

      pdf.table(guests_summary, width: pdf.bounds.width, cell_style: { borders: [] }) do
        column(0).style(font_style: :bold, width: 150)
      end

      pdf.move_down 20

      # Providers cost sheet
      event_providers = event.event_providers.includes(:provider)
      if event_providers.any?
        pdf.font_size 16
        pdf.text "Fornecedores - Planilha de custos", style: :bold
        pdf.move_down 10

        pdf.font_size 10
        providers_data = [ [ "Tipo", "Fornecedor", "Contato", "Status", "Profissionais", "Valor" ] ]
        event_providers.each do |ep|
          provider = ep.provider
          providers_data << [
            translate_provider_type(provider.provider_type),
            provider.name,
            provider.contact_name,
            translate_provider_status(ep.status),
            ep.professionals_count.to_s,
            format_brl(ep.value)
          ]
        end
        providers_data << [
          "Totais", "", "", "",
          event.providers_total_professionals.to_s,
          format_brl(event.providers_total_cost)
        ]

        pdf.table(providers_data, header: true, width: pdf.bounds.width) do
          row(0).font_style = :bold
          row(-1).font_style = :bold
          self.header = true
        end

        pdf.move_down 6
        pdf.font_size 11
        pdf.text "Total pago: #{format_brl(event.providers_paid_total)}  •  Saldo a pagar: #{format_brl(event.providers_balance)}", style: :bold

        pdf.move_down 20
      end

      # Tasks Summary
      manager_pending = event.manager_checklists.pending.count
      manager_total = event.manager_checklists.count
      owner_pending = event.owner_checklists.pending.count
      owner_total = event.owner_checklists.count

      if manager_total > 0 || owner_total > 0
        pdf.font_size 16
        pdf.text "Resumo de Tarefas", style: :bold
        pdf.move_down 10

        pdf.font_size 12
        tasks_summary = [
          [ "Checklist interno:", "#{manager_total - manager_pending}/#{manager_total} concluídas" ],
          [ "Checklist Responsáveis:", "#{owner_total - owner_pending}/#{owner_total} concluídas" ]
        ]

        pdf.table(tasks_summary, width: pdf.bounds.width, cell_style: { borders: [] }) do
          column(0).style(font_style: :bold, width: 200)
        end

        pdf.move_down 20
      end

      # Footer
      pdf.move_down 30
      pdf.font_size 10
      pdf.text "Gerado por Cerimonial.app em #{Time.current.strftime('%d/%m/%Y às %H:%M')}",
               align: :center, style: :italic
    end.render
  end

  # Termination penalty owed by the CONTRATANTE (clause 7ª).
  TERMINATION_PENALTY_RATE = 0.30
  # Default reception hours included before extra hours kick in (clause 3ª, II).
  DEFAULT_RECEPTION_HOURS = 6

  # CONTRATADA (service provider) identity printed on the contract header.
  def self.company_name
    ENV["CONTRACT_COMPANY_NAME"].presence || "ANAILDE COELHO EVENTOS"
  end

  def self.company_cnpj
    ENV["CONTRACT_COMPANY_CNPJ"].presence || "16.666.264/0001-19"
  end

  def self.company_address
    ENV["CONTRACT_COMPANY_ADDRESS"].presence || "Rua Euzébio de Sousa, 379, Fortaleza/CE"
  end

  def self.forum_city
    ENV["CONTRACT_FORUM_CITY"].presence || "Fortaleza, Estado do Ceará"
  end

  # Renders the service contract following the company's clause template,
  # merging the event + contratante (event_owner) data.
  def self.generate_contract_pdf(event)
    contratante = event.event_owners.first
    reception_hours = event.extra_hours.present? ? DEFAULT_RECEPTION_HOURS + event.extra_hours : DEFAULT_RECEPTION_HOURS

    Prawn::Document.new do |pdf|
      pdf.font_size 12
      pdf.text "CONTRATO DE PRESTAÇÃO DE SERVIÇOS ESPECIALIZADOS EM COORDENAÇÃO DE EVENTOS",
               align: :center, style: :bold
      pdf.move_down 16

      pdf.font_size 11

      # Preâmbulo (qualificação das partes)
      preamble = "Por meio deste instrumento particular, de um lado, #{company_name}, " \
                 "inscrita no CNPJ #{company_cnpj}, estabelecida na #{company_address}, " \
                 "doravante denominada CONTRATADA, e de outro lado, " \
                 "#{(contratante&.name.presence || '____________________').upcase}, " \
                 "CPF #{format_cpf(contratante&.cpf)}, denominada simplesmente CONTRATANTE, " \
                 "têm justo e acertado celebrar o presente CONTRATO DE PRESTAÇÃO DE SERVIÇOS " \
                 "ESPECIALIZADOS EM COORDENAÇÃO DE EVENTOS, mediante as cláusulas e condições " \
                 "mencionadas a seguir, as quais se obrigam mutuamente a cumprir e a fazer cumprir:"
      pdf.text preamble, align: :justify
      pdf.move_down 14

      # Do objeto
      pdf.text "DO OBJETO DO PRESENTE CONTRATO", style: :bold
      pdf.move_down 4
      pdf.text "Cláusula 1ª. O presente contrato tem por objeto a prestação de serviços técnicos " \
               "especializados, por parte da CONTRATADA para o serviço DE ASSESSORIA, ORGANIZAÇÃO " \
               "E PLANEJAMENTO DE #{translate_event_type(event.event_type).upcase} a ser celebrado " \
               "no dia #{event.main_date.strftime('%d/%m/%Y')}#{event_place_clause(event)}, utilizando " \
               "na execução dos serviços mão de obra especializada/treinada, mediante planejamento, " \
               "bem como capacitada, a utilizar-se de mecanização e tecnologia, quando for necessário " \
               "para a boa execução dos serviços;", align: :justify
      pdf.move_down 8
      pdf.text "Parágrafo primeiro. O presente contrato é regulado pelos ditames civis previstos nos " \
               "artigos 593 a 609, do Capítulo VII (DA PRESTAÇÃO DE SERVIÇOS), DO DIREITO DAS " \
               "OBRIGAÇÕES, do Código Civil Brasileiro.", align: :justify
      pdf.move_down 14

      # Da execução dos serviços
      pdf.text "DA EXECUÇÃO DOS SERVIÇOS", style: :bold
      pdf.move_down 4
      pdf.text "Cláusula 2ª. Os serviços serão prestados pela CONTRATADA mediante pessoal habilitado " \
               "em número mínimo de #{receptionists_text(event)} E A CONTRATADA.", align: :justify
      pdf.move_down 14

      # Das obrigações da contratada
      pdf.text "DAS OBRIGAÇÕES DA CONTRATADA", style: :bold
      pdf.move_down 4
      pdf.text "Cláusula 3ª. A CONTRATADA, além da boa e fiel execução dos serviços contratados se obriga a:",
               align: :justify
      pdf.move_down 6
      pdf.text "I- Planejar, executar, administrar, coordenar todas as ações relativas ao objeto deste " \
               "instrumento, sempre sob apreciação e respectiva autorização do CONTRATANTE;", align: :justify
      pdf.move_down 4
      pdf.text "II- Acompanhar o CONTRATANTE em todo o evento acertado, desde o início do evento até o " \
               "término do mesmo (CERIMÔNIA + #{format_hours(reception_hours)} HORAS DE RECEPÇÃO). " \
               "Será cobrada hora extra a partir do horário final definido no contrato#{extra_hour_rate_clause(event)};",
               align: :justify
      pdf.move_down 4
      pdf.text "III- Executar os serviços de acordo com os prazos negociados;", align: :justify
      pdf.move_down 4
      pdf.text "IV- Responsabilizar-se exclusivamente por todas as despesas e obrigações relativas à " \
               "previdência social e implicações de natureza trabalhista e fiscal de seus empregados;",
               align: :justify
      pdf.move_down 4
      pdf.text "V- Caso haja o adiamento do evento por motivos de força maior ou pandemia, não haverá " \
               "cobrança de multa. Neste caso será feito o agendamento de nova data, levando em " \
               "consideração a disponibilidade da CONTRATADA.", align: :justify
      pdf.move_down 14

      # Das obrigações do contratante
      pdf.text "DAS OBRIGAÇÕES DO CONTRATANTE", style: :bold
      pdf.move_down 4
      pdf.text "Cláusula 4ª. São obrigações do CONTRATANTE, além das demais previstas ou decorrentes do contrato:",
               align: :justify
      pdf.move_down 6
      pdf.text "I - Fornecer à CONTRATADA todos os subsídios necessários ao desempenho da atividade objeto " \
               "deste contrato, assim como cumprir integralmente o que fora pactuado;", align: :justify
      pdf.move_down 4
      pdf.text "II - Definir com detalhes específicos, por escrito, os compromissos que deseja realizar, sob " \
               "pena de indefinição e cancelamento do evento, em seu prejuízo, caso seja o responsável;", align: :justify
      pdf.move_down 4
      pdf.text "III - Proceder ao pagamento acertado com a CONTRATADA da forma estabelecida neste instrumento;",
               align: :justify
      pdf.move_down 4
      pdf.text "IV - Comunicar a CONTRATADA, POR ESCRITO, COM ANTECEDÊNCIA MÍNIMA DE 60 DIAS, qualquer " \
               "alteração a ser feita em relação ao evento anteriormente acordado;", align: :justify
      pdf.move_down 4
      pdf.text "V - A comunicação da desistência ou a falta em algum dos eventos não desobriga o CONTRATANTE " \
               "das obrigações já estabelecidas e do que já fora acertado.", align: :justify
      pdf.move_down 14

      # Dos valores e das condições de pagamento
      pdf.text "DOS VALORES E DAS CONDIÇÕES DE PAGAMENTO", style: :bold
      pdf.move_down 4
      pdf.text "Cláusula 5ª. Pela prestação dos serviços objeto deste contrato, o CONTRATANTE pagará, a " \
               "título de remuneração, #{payment_due_clause(event)}à CONTRATADA, a importância de " \
               "#{format_currency(event.contract_total_value)}, valor este definido conforme orçamento " \
               "anexo a este contrato.", align: :justify
      pdf.move_down 8
      pdf.text "Parágrafo primeiro. Os valores acima acertados poderão ser pagos à vista ou parcelados, a " \
               "contar da data da assinatura deste contrato.", align: :justify
      pdf.move_down 4
      pdf.text "Parágrafo segundo. Em caso de pagamento por meio de cheque ou qualquer outro título de " \
               "crédito, somente será dada quitação após a devida compensação do título dado como pagamento.",
               align: :justify
      pdf.move_down 4
      pdf.text "Parágrafo terceiro. O atraso do pagamento ou seu total inadimplemento implicará na cobrança " \
               "de multa de 2% (dois por cento) ao mês, de acordo com o parágrafo primeiro, do artigo 52, " \
               "da Lei nº 8.078/90, acrescidos de juros moratórios, além da correção monetária da " \
               "importância em mora, sem prejuízo de honorários advocatícios quando a cobrança se proceder " \
               "judicialmente.", align: :justify
      pdf.move_down 14

      # Das penalidades
      pdf.text "DAS PENALIDADES", style: :bold
      pdf.move_down 4
      pdf.text "Cláusula 6ª. A CONTRATADA, em caso de desistência durante a vigência do presente contrato, " \
               "deverá restituir à CONTRATANTE o valor integralmente pago.", align: :justify
      pdf.move_down 6
      pdf.text "Cláusula 7ª. O CONTRATANTE, em caso de desistência durante a vigência do presente contrato, " \
               "em decorrência das despesas administrativas e outros encargos da CONTRATADA, deverá pagar " \
               "#{(TERMINATION_PENALTY_RATE * 100).to_i}% (trinta por cento) do valor total firmado no " \
               "contrato#{penalty_amount_clause(event)}.", align: :justify
      pdf.move_down 14

      # Da vigência do contrato
      pdf.text "DA VIGÊNCIA DO CONTRATO", style: :bold
      pdf.move_down 4
      pdf.text "Cláusula 8ª. O presente contrato é firmado a contar da data de assinatura do mesmo, com termo " \
               "final no horário previamente definido de acordo com a 3ª cláusula.", align: :justify
      pdf.move_down 6
      pdf.text "Cláusula 9ª. Para dirimir quaisquer controvérsias oriundas do presente contrato, as partes " \
               "elegem o foro da comarca de #{forum_city}.", align: :justify
      pdf.move_down 14

      pdf.text "E, por estarem justas e contratadas, as partes assinam o presente instrumento em duas (02) " \
               "vias de igual teor e forma.", align: :justify
      pdf.move_down 36

      # Assinaturas
      pdf.text "CONTRATANTE   __________________________________"
      pdf.move_down 4
      pdf.text contratante.name.to_s, indent_paragraphs: 30 if contratante&.name.present?
      pdf.move_down 24
      pdf.text "CONTRATADA    __________________________________"
      pdf.move_down 4
      pdf.text company_name, indent_paragraphs: 30

      pdf.move_down 30
      city = forum_city.split(",").first
      pdf.text "#{city}, #{Date.current.strftime('%d/%m/%Y')}.", align: :center
    end.render
  end

  def self.event_place_clause(event)
    return "" if event.place.blank?

    ", no local #{event.place}"
  end

  # "03 (TRÊS) RECEPCIONISTAS" — count + spelled-out word from the contract field.
  def self.receptionists_text(event)
    count = event.contract_receptionists_count
    return "_____ RECEPCIONISTAS" if count.blank?

    word = number_in_words(count)
    "#{format('%02d', count)} (#{word}) RECEPCIONISTA#{'S' if count != 1}"
  end

  def self.extra_hour_rate_clause(event)
    return "" if event.contract_extra_hour_rate.blank?

    ", no valor de #{format_currency(event.contract_extra_hour_rate)} por hora"
  end

  def self.payment_due_clause(event)
    return "" if event.contract_payment_due_date.blank?

    "até a data de #{event.contract_payment_due_date.strftime('%d/%m/%Y')}, "
  end

  def self.penalty_amount_clause(event)
    return "" if event.contract_total_value.blank?

    amount = event.contract_total_value * TERMINATION_PENALTY_RATE
    ", equivalente a #{format_currency(amount)}"
  end

  # Formats reception hours dropping a trailing ".0" (6.0 -> "6", 6.5 -> "6,5").
  def self.format_hours(value)
    format("%g", value).tr(".", ",")
  end

  # Spells out small integers in Portuguese for the receptionists clause.
  NUMBER_WORDS = %w[zero um dois três quatro cinco seis sete oito nove dez].freeze

  def self.number_in_words(count)
    NUMBER_WORDS[count]&.upcase || count.to_s
  end

  # Formats a decimal as Brazilian Real: R$ 1.234,56.
  def self.format_currency(value)
    return "—" if value.blank?

    formatted = format("%.2f", value)
    integer, decimals = formatted.split(".")
    integer = integer.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
    "R$ #{integer},#{decimals}"
  end

  # Formats 11 CPF digits as 000.000.000-00.
  def self.format_cpf(value)
    digits = value.to_s.gsub(/\D/, "")
    return "—" unless digits.length == 11

    "#{digits[0, 3]}.#{digits[3, 3]}.#{digits[6, 3]}-#{digits[9, 2]}"
  end

  # Build the provider cost-sheet workbook (one "Planilha de custos" sheet) and
  # return the serialized xlsx bytes.
  def self.generate_xlsx_cost_sheet(event)
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: "Planilha de custos") do |sheet|
      header = sheet.styles.add_style(b: true, bg_color: "F2F2F2")
      money = sheet.styles.add_style(format_code: '"R$" #,##0.00')
      total = sheet.styles.add_style(b: true)

      sheet.add_row [ "Tipo", "Fornecedor", "Contato", "Telefone", "Status", "Profissionais", "Valor", "Observações" ], style: header

      event.event_providers.includes(:provider).each do |ep|
        provider = ep.provider
        sheet.add_row [
          translate_provider_type(provider.provider_type),
          provider.name,
          provider.contact_name,
          format_phone(provider.phone_number),
          translate_provider_status(ep.status),
          ep.professionals_count,
          ep.value,
          ep.custom_detail(:notes)
        ], style: [ nil, nil, nil, nil, nil, nil, money, nil ]
      end

      sheet.add_row [
        "Totais", "", "", "", "",
        event.providers_total_professionals,
        event.providers_total_cost,
        ""
      ], style: [ total, nil, nil, nil, nil, total, money, nil ]
      sheet.add_row [ "Total pago", "", "", "", "", "", event.providers_paid_total, "" ], style: [ total, nil, nil, nil, nil, nil, money, nil ]
      sheet.add_row [ "Saldo a pagar", "", "", "", "", "", event.providers_balance, "" ], style: [ total, nil, nil, nil, nil, nil, money, nil ]
    end

    package.to_stream.read
  end
end
