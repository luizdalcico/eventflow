module Admin
  class GodparentListsController < ApplicationController
    before_action :set_event

    def create
      return redirect_to @event, alert: "Lista de padrinhos só está disponível para casamentos." unless @event.wedding?

      list = @event.godparent_list || @event.build_godparent_list
      list.assign_attributes(godparent_list_params)
      list.regenerate_token if list.token.blank?

      if list.save
        redirect_to @event, notice: "Link de preenchimento da lista de padrinhos gerado com sucesso!"
      else
        redirect_to @event, alert: "Não foi possível gerar o link: #{list.errors.full_messages.to_sentence}"
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
