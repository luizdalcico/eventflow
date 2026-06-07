module Admin
  class GodparentListsController < ApplicationController
    before_action :set_event

    def create
      return redirect_to @event, alert: "Lista de padrinhos só está disponível para casamentos." unless @event.wedding?

      list = @event.find_or_create_godparent_list!

      if list.update(godparent_list_params)
        redirect_to event_guests_path(@event), notice: "Lista de padrinhos atualizada com sucesso!"
      else
        redirect_to event_guests_path(@event), alert: "Não foi possível atualizar a lista: #{list.errors.full_messages.to_sentence}"
      end
    end

    private

    def set_event
      @event = Event.find(params[:event_id])
    end

    def godparent_list_params
      params.fetch(:godparent_list, {}).permit(:expires_at)
    end
  end
end
