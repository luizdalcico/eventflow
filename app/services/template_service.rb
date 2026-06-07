class TemplateService
  extend ApplicationHelper

  def self.generate_event_report(event, format = :pdf)
    case format.to_sym
    when :pdf
      generate_pdf_report(event)
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

      # Providers
      if event.providers.any?
        pdf.font_size 16
        pdf.text "Fornecedores", style: :bold
        pdf.move_down 10

        pdf.font_size 12
        providers_data = [ [ "Tipo", "Nome", "Contato", "Telefone" ] ]
        event.providers.includes(:event_providers).each do |provider|
          providers_data << [
            translate_provider_type(provider.provider_type),
            provider.name,
            provider.contact_name,
            provider.phone_number
          ]
        end

        pdf.table(providers_data, header: true, width: pdf.bounds.width) do
          row(0).font_style = :bold
          self.header = true
        end

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

  # Penalty applied over the total value on contract termination.
  TERMINATION_PENALTY_RATE = 0.30

  def self.company_name
    ENV["RSVP_COMPANY_NAME"].presence || "Cerimonial.app"
  end

  def self.generate_contract_pdf(event)
    contratante = event.event_owners.first

    Prawn::Document.new do |pdf|
      # Company header
      pdf.font_size 18
      pdf.text company_name, align: :center, style: :bold
      pdf.move_down 4
      pdf.font_size 13
      pdf.text "Contrato de Prestação de Serviços", align: :center, style: :bold
      pdf.move_down 20

      pdf.font_size 11

      # Objeto
      pdf.text "1. DO OBJETO", style: :bold
      pdf.move_down 4
      objeto = "O presente contrato tem por objeto a prestação de serviços de cerimonial " \
               "para o evento do tipo #{translate_event_type(event.event_type)}, " \
               "a ser realizado em #{event.main_date.strftime('%d/%m/%Y')}" \
               "#{event_time_clause(event)}#{event_place_clause(event)}."
      pdf.text objeto, align: :justify
      pdf.move_down 12

      # Contratante
      pdf.text "2. DO CONTRATANTE", style: :bold
      pdf.move_down 4
      pdf.text "Nome: #{contratante&.name.presence || '—'}"
      pdf.text "CPF: #{format_cpf(contratante&.cpf)}"
      pdf.move_down 12

      # Obrigações
      pdf.text "3. DAS OBRIGAÇÕES", style: :bold
      pdf.move_down 4
      pdf.text "Nº de recepcionistas: #{event.contract_receptionists_count || '—'}"
      pdf.text "Horas de recepção (extras): #{event.extra_hours.present? ? format('%g', event.extra_hours) : '0'}"
      pdf.text "Valor da hora extra: #{format_currency(event.contract_extra_hour_rate)}"
      pdf.move_down 12

      # Pagamento
      pdf.text "4. DO PAGAMENTO", style: :bold
      pdf.move_down 4
      pdf.text "Valor total: #{format_currency(event.contract_total_value)}"
      pdf.text "Data limite de pagamento: #{event.contract_payment_due_date&.strftime('%d/%m/%Y') || '—'}"
      pdf.move_down 12

      # Penalidades
      pdf.text "5. DAS PENALIDADES", style: :bold
      pdf.move_down 4
      penalty = "Em caso de rescisão por parte do CONTRATANTE, será devida multa de " \
                "#{(TERMINATION_PENALTY_RATE * 100).to_i}% (trinta por cento) sobre o valor total do contrato" \
                "#{penalty_amount_clause(event)}."
      pdf.text penalty, align: :justify
      pdf.move_down 12

      # Vigência
      pdf.text "6. DA VIGÊNCIA", style: :bold
      pdf.move_down 4
      pdf.text "O presente contrato vigora a partir de sua assinatura até a conclusão dos " \
               "serviços contratados, referentes à data do evento.", align: :justify
      pdf.move_down 12

      # Foro
      pdf.text "7. DO FORO", style: :bold
      pdf.move_down 4
      pdf.text "Fica eleito o foro da comarca de domicílio do CONTRATANTE para dirimir " \
               "quaisquer questões oriundas do presente contrato.", align: :justify
      pdf.move_down 30

      # Signatures
      pdf.text "_________________________________", align: :center
      pdf.text company_name, align: :center
      pdf.move_down 16
      pdf.text "_________________________________", align: :center
      pdf.text "Contratante: #{contratante&.name.presence || ''}", align: :center

      pdf.move_down 24
      pdf.font_size 9
      pdf.text "Gerado por Cerimonial.app em #{Time.current.strftime('%d/%m/%Y às %H:%M')}",
               align: :center, style: :italic
    end.render
  end

  def self.event_time_clause(event)
    return "" unless event.start_time && event.end_time

    ", das #{event.start_time.strftime('%H:%M')} às #{event.end_time.strftime('%H:%M')}"
  end

  def self.event_place_clause(event)
    return "" if event.place.blank?

    ", no local #{event.place}"
  end

  def self.penalty_amount_clause(event)
    return "" if event.contract_total_value.blank?

    amount = event.contract_total_value * TERMINATION_PENALTY_RATE
    ", equivalente a #{format_currency(amount)}"
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
end
