class EventDatesController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_event
  before_action :set_date, only: %i[update destroy]

  def index
    @event_dates = @event.event_dates.order(:date)
    @event_date = @event.event_dates.new
  end

  def create
    @event_date = @event.event_dates.new(date_params)
    if @event_date.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("event_dates_empty"),
            turbo_stream.append("event_dates", partial: "event_dates/event_date", locals: { event: @event, event_date: @event_date }),
            turbo_stream.replace("new_event_date", partial: "event_dates/form", locals: { event: @event, event_date: @event.event_dates.new })
          ]
        end
        format.html { redirect_to event_event_dates_path(@event) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_event_date", partial: "event_dates/form", locals: { event: @event, event_date: @event_date }) }
        format.html { redirect_to event_event_dates_path(@event), alert: @event_date.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    @event_date.update(date_params)
    head :no_content
  end

  def destroy
    @event_date.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@event_date)) }
      format.html { redirect_to event_event_dates_path(@event) }
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_date
    @event_date = @event.event_dates.find(params[:id])
  end

  def date_params
    params.require(:event_date).permit(:description, :date)
  end
end
