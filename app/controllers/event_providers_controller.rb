class EventProvidersController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_event
  before_action :set_event_provider, only: %i[destroy update_details]

  def index
    @event_providers = @event.event_providers.includes(:provider)
    @available_providers = available_providers
  end

  def export
    respond_to do |format|
      format.xlsx do
        send_data TemplateService.generate_event_report(@event, :xlsx),
                  filename: "planilha_custos_#{@event.id}_#{Date.current.strftime('%Y%m%d')}.xlsx",
                  type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                  disposition: "attachment"
      end
    end
  end

  def create
    @event_provider = @event.event_providers.new(provider_id: params[:provider_id])
    if @event_provider.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("event_providers_empty"),
            turbo_stream.append("event_providers", partial: "event_providers/event_provider", locals: { event: @event, event_provider: @event_provider }),
            turbo_stream.replace("add_provider", partial: "event_providers/add_form", locals: { event: @event, available_providers: available_providers }),
            turbo_stream.replace("providers_totals", partial: "event_providers/totals", locals: { event: @event })
          ]
        end
        format.html { redirect_to event_event_providers_path(@event) }
      end
    else
      redirect_to event_event_providers_path(@event), alert: "Selecione um fornecedor válido."
    end
  end

  def update_details
    attrs = column_detail_attributes
    # Free-text notes stay in the custom_details JSON; they are not aggregated.
    if detail_params.key?(:notes)
      attrs[:custom_details] = (@event_provider.custom_details || {}).merge("notes" => detail_params[:notes])
    end
    @event_provider.update(attrs)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "providers_totals",
          partial: "event_providers/totals",
          locals: { event: @event }
        )
      end
      format.html { head :no_content }
    end
  end

  def destroy
    @event_provider.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(dom_id(@event_provider)),
          turbo_stream.replace("add_provider", partial: "event_providers/add_form", locals: { event: @event, available_providers: available_providers }),
          turbo_stream.replace("providers_totals", partial: "event_providers/totals", locals: { event: @event })
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
    params.require(:event_provider).permit(:value, :status, :professionals_count, :notes)
  end

  # Build the real-column attributes present in this request, parsing the
  # BRL-formatted value field into a decimal. Keys absent from the form are skipped.
  def column_detail_attributes
    attrs = {}
    attrs[:value] = EventProvider.parse_brl(detail_params[:value]) if detail_params.key?(:value)
    attrs[:status] = detail_params[:status] if detail_params.key?(:status)
    attrs[:professionals_count] = detail_params[:professionals_count] if detail_params.key?(:professionals_count)
    attrs
  end
end
