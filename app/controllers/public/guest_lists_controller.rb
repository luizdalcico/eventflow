module Public
  class GuestListsController < BaseController
    before_action :require_editable!, only: %i[finalize]

    def show
      @guests = @event.guests.order(:name)
    end

    def finalize
      @list.finalize!
      # Recarrega a página em todos os navegadores conectados (trava a edição para todos).
      Turbo::StreamsChannel.broadcast_refresh_to(@list)
      redirect_to guest_list_path(@list.token), notice: "Lista finalizada! O cerimonial foi avisado."
    end

    private

    def find_list(token)
      GuestList.find_by(token: token)
    end

    def editable_redirect_path
      guest_list_path(@list.token)
    end
  end
end
