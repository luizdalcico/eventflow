class PendenciesController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_event
  before_action :set_pendency, only: %i[update destroy]

  def create
    @pendency = @event.pendencies.new(pendency_params)
    if @pendency.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(list_empty_id),
            turbo_stream.append(list_id, partial: "pendencies/pendency", locals: { event: @event, pendency: @pendency }),
            turbo_stream.replace(form_id, partial: "pendencies/form", locals: { event: @event, pendency: reset_pendency })
          ]
        end
        format.html { redirect_to redirect_target }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(form_id, partial: "pendencies/form", locals: { event: @event, pendency: @pendency }) }
        format.html { redirect_to redirect_target, alert: @pendency.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    @pendency.update(pendency_params)
    head :no_content
  end

  def destroy
    @pendency.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@pendency)) }
      format.html { redirect_to redirect_target }
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_pendency
    @pendency = @event.pendencies.find(params[:id])
  end

  def pendency_params
    params.require(:pendency).permit(:description, :assignee, :status, :due_date, :meeting_id, :event_provider_id)
  end

  # A fresh pendency keeping the same meeting binding so the reset form stays in
  # the meeting context when adding several items in a row.
  def reset_pendency
    @event.pendencies.new(meeting_id: @pendency.meeting_id)
  end

  # The DOM ids differ per context (a specific meeting vs the general list) so
  # multiple pendency lists never collide on the same page.
  def list_id
    @pendency.meeting_id.present? ? "meeting_#{@pendency.meeting_id}_pendencies" : "general_pendencies"
  end

  def list_empty_id
    "#{list_id}_empty"
  end

  def form_id
    @pendency.meeting_id.present? ? "new_meeting_#{@pendency.meeting_id}_pendency" : "new_general_pendency"
  end

  def redirect_target
    @pendency.meeting_id.present? ? event_meeting_path(@event, @pendency.meeting_id) : event_meetings_path(@event)
  end
end
