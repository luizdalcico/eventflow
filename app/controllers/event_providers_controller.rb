class EventProvidersController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_event
  before_action :set_event_provider, only: %i[destroy update_details]

  def index
    @event_providers = @event.event_providers.includes(:provider)
    @available_providers = available_providers
  end

  def create
    @event_provider = @event.event_providers.new(provider_id: params[:provider_id])
    if @event_provider.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("event_providers_empty"),
            turbo_stream.append("event_providers", partial: "event_providers/event_provider", locals: { event: @event, event_provider: @event_provider }),
            turbo_stream.replace("add_provider", partial: "event_providers/add_form", locals: { event: @event, available_providers: available_providers })
          ]
        end
        format.html { redirect_to event_event_providers_path(@event) }
      end
    else
      redirect_to event_event_providers_path(@event), alert: "Selecione um fornecedor válido."
    end
  end

  def update_details
    details = (@event_provider.custom_details || {}).merge(detail_params.to_h)
    @event_provider.update(custom_details: details)
    head :no_content
  end

  def destroy
    @event_provider.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(dom_id(@event_provider)),
          turbo_stream.replace("add_provider", partial: "event_providers/add_form", locals: { event: @event, available_providers: available_providers })
        ]
      end
      format.html { redirect_to event_event_providers_path(@event) }
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_event_provider
    @event_provider = @event.event_providers.find(params[:id])
  end

  def available_providers
    Provider.where.not(id: @event.event_providers.map(&:provider_id)).order(:provider_type, :name)
  end

  def detail_params
    params.require(:event_provider).permit(:value, :notes)
  end
end
