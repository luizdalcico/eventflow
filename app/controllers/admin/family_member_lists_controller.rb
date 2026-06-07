module Admin
  class FamilyMemberListsController < ApplicationController
    before_action :set_event

    def create
      return redirect_to @event, alert: "Lista de familiares só está disponível para casamentos." unless @event.wedding?

      list = @event.find_or_create_family_member_list!

      if list.update(family_member_list_params)
        redirect_to event_guests_path(@event), notice: "Link de familiares atualizado com sucesso!"
      else
        redirect_to event_guests_path(@event), alert: "Não foi possível atualizar o link: #{list.errors.full_messages.to_sentence}"
      end
    end

    private

    def set_event
      @event = Event.find(params[:event_id])
    end

    def family_member_list_params
      params.fetch(:family_member_list, {}).permit(:expires_at)
    end
  end
end
