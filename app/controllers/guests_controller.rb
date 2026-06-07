class GuestsController < ApplicationController
  before_action :set_event

  def index
    @guests = @event.guests.order(:name)
    # Wedding-only tabs: godparents (paired) and family members.
    if @event.wedding?
      # Weddings predating auto-generation get their list created on first view.
      @godparent_list = @event.find_or_create_godparent_list!
      # Preload the paired padrinho to avoid an N+1 when rendering each pair row.
      @anchors = @event.godparents.anchors.includes(:pair)
      @family_members = @event.family_members.ordered
      @family_member = @event.family_members.new
    end
  end

  # Lista pronta para impressão (Imprimir / Salvar em PDF pelo navegador).
  def print
    @guests = @event.guests.order(:guest_type, :name)
    render layout: "print"
  end

  # Exporta a lista de convidados como planilha .xlsx.
  def export
    guests = @event.guests.order(:guest_type, :name)
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: "Convidados") do |sheet|
      header = sheet.styles.add_style(b: true, bg_color: "EEEEEE", border: { style: :thin, color: "BBBBBB" })
      sheet.add_row [ "Nome", "Tipo", "Pessoas", "Telefone", "RSVP", "Observações" ], style: header
      guests.each do |guest|
        sheet.add_row [
          guest.name,
          helpers.guest_type_label(guest.guest_type),
          guest.party_size,
          guest.phone_number,
          helpers.rsvp_label(guest.rsvp_status),
          guest.notes
        ]
      end
      sheet.column_widths 28, 12, 10, 20, 14, 24
    end

    send_data package.to_stream.read,
              filename: "convidados_#{@event.id}.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
              disposition: "attachment"
  end

  def create
    @guest = @event.guests.create!
    respond_to do |format|
      format.turbo_stream # create.turbo_stream.erb (append da linha)
      format.html { redirect_to event_guests_path(@event) }
    end
  end

  def update
    guest = @event.guests.find(params[:id])
    guest.assign_attributes(guest_params)
    # Marcação manual de RSVP: carimba a data da resposta.
    if guest.rsvp_status_changed? && %w[confirmed declined].include?(guest.rsvp_status) && guest.rsvp_responded_at.blank?
      guest.rsvp_responded_at = Time.current
    end
    guest.save!
    head :ok
  end

  def destroy
    @event.guests.find(params[:id]).destroy!
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("guest_#{params[:id]}") }
      format.html { redirect_to event_guests_path(@event) }
    end
  end

  def template
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: "Convidados") do |sheet|
      header = sheet.styles.add_style(b: true, bg_color: "EEEEEE", border: { style: :thin, color: "BBBBBB" })
      sheet.add_row [ "Nome", "Quantidade de convidados", "Tipo", "Telefone", "Observações" ], style: header
      sheet.add_row [ "João Silva", 2, "Adulto", "(85) 99999-0000", "" ]
      sheet.add_row [ "Maria Souza", 1, "Adulto", "(85) 98888-0000", "Mesa 3" ]
      sheet.add_row [ "Lucas Souza", 1, "Criança", "", "" ]
      sheet.column_widths 28, 22, 12, 20, 24
    end

    send_data package.to_stream.read,
              filename: "modelo_convidados.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
              disposition: "attachment"
  end

  def import
    if params[:file].blank?
      redirect_to event_guests_path(@event), alert: "Selecione um arquivo .xlsx ou .csv." and return
    end

    result = GuestImport.new(@event, params[:file]).call

    if result.imported.positive?
      notice = "#{result.imported} convidado(s) importado(s)."
      notice += " #{result.skipped} linha(s) ignorada(s)." if result.skipped.positive?
      redirect_to event_guests_path(@event), notice: notice
    else
      redirect_to event_guests_path(@event), alert: result.errors.first || "Nenhum convidado importado."
    end
  end

  def send_rsvp
    candidates =
      if params[:all].present?
        @event.guests.with_phone.to_a
      else
        ids = Array(params[:guest_ids]).map(&:to_i)
        @event.guests.where(id: ids).to_a
      end

    # Não reenvia para quem já recebeu/respondeu.
    guests = candidates.select(&:rsvp_sendable?)
    skipped = candidates.size - guests.size

    if guests.empty?
      message = params[:all].present? ? "Nenhum convidado pendente para enviar." : "Nenhum convidado pendente selecionado (já enviados ou sem telefone)."
      redirect_to event_guests_path(@event), alert: message and return
    end

    guests.each { |g| SendRsvpJob.perform_later(g.id) }

    if Rsvp::Sender.configured?
      notice = "Convite de RSVP enviado para #{guests.size} convidado(s)."
      notice += " #{skipped} pulado(s) (já enviados ou sem telefone)." if skipped.positive?
    else
      notice = "Twilio não está configurado — defina as variáveis de ambiente para enviar de verdade."
    end
    redirect_to event_guests_path(@event), notice: notice
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def guest_params
    permitted = params.require(:guest).permit(:name, :phone_number, :party_size, :notes, :rsvp_status, :guest_type)
    permitted[:phone_number] = permitted[:phone_number].gsub(/\D/, "") if permitted[:phone_number].present?
    permitted
  end
end
