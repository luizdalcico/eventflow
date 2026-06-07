module Public
  # Página pública: convidados se cadastram na lista do evento (linha plana).
  class PublicGuestsController < BaseController
    before_action :require_editable!, except: %i[template]

    def create
      @guest = @event.guests.create!

      respond_to do |format|
        format.turbo_stream # create.turbo_stream.erb (append da linha)
        format.html { redirect_to guest_list_path(@list.token) }
      end
    end

    def update
      guest = @event.guests.find(params[:id])
      guest.update!(guest_params)
      head :ok
    end

    def destroy
      guest = @event.guests.find(params[:id])
      guest.destroy!

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove("guest_#{guest.id}") }
        format.html { redirect_to guest_list_path(@list.token) }
      end
    end

    def import
      if params[:file].blank?
        redirect_to guest_list_path(@list.token), alert: "Selecione um arquivo .xlsx ou .csv." and return
      end

      result = GuestImport.new(@event, params[:file]).call

      if result.imported.positive?
        notice = "#{result.imported} convidado(s) importado(s)."
        notice += " #{result.skipped} linha(s) ignorada(s)." if result.skipped.positive?
        redirect_to guest_list_path(@list.token), notice: notice
      else
        redirect_to guest_list_path(@list.token), alert: result.errors.first || "Nenhum convidado importado."
      end
    end

    def template
      send_data GuestTemplate.xlsx,
                filename: GuestTemplate::FILENAME,
                type: GuestTemplate::CONTENT_TYPE,
                disposition: "attachment"
    end

    private

    def find_list(token)
      GuestList.find_by(token: token)
    end

    def editable_redirect_path
      guest_list_path(@list.token)
    end

    def guest_params
      permitted = params.require(:guest).permit(:name, :phone_number, :party_size, :notes, :guest_type)
      permitted[:phone_number] = permitted[:phone_number].gsub(/\D/, "") if permitted[:phone_number].present?
      permitted[:guest_type] = permitted[:guest_type].presence_in(Guest::GUEST_TYPES) if permitted.key?(:guest_type)
      permitted
    end
  end
end
