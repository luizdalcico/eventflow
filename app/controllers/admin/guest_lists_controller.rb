module Admin
  class GuestListsController < ApplicationController
    before_action :set_event

    def create
      list = @event.find_or_create_guest_list!

      if list.update(guest_list_params)
        redirect_to event_guests_path(@event), notice: "Link de convidados atualizado com sucesso!"
      else
        redirect_to event_guests_path(@event), alert: "Não foi possível atualizar o link: #{list.errors.full_messages.to_sentence}"
      end
    end

    private

    def set_event
      @event = Event.find(params[:event_id])
    end

    def guest_list_params
      params.fetch(:guest_list, {}).permit(:expires_at)
    end
  end
end
