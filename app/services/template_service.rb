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
end
