module Public
  # Página pública: convidados se cadastram na lista do evento (linha plana).
  class PublicGuestsController < BaseController
    before_action :require_editable!

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
