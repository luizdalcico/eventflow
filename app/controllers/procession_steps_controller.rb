class ProcessionStepsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_event
  before_action :set_step, only: %i[update destroy]

  def create
    next_position = (@event.procession_steps.maximum(:position) || 0) + 1
    @procession_step = @event.procession_steps.new(step_params.merge(position: next_position))
    if @procession_step.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("procession_steps_empty"),
            turbo_stream.append("procession_steps", partial: "procession_steps/procession_step", locals: { event: @event, procession_step: @procession_step }),
            turbo_stream.replace("new_procession_step", partial: "procession_steps/form", locals: { event: @event, procession_step: @event.procession_steps.new })
          ]
        end
        format.html { redirect_to event_cortejo_path(@event) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_procession_step", partial: "procession_steps/form", locals: { event: @event, procession_step: @procession_step }) }
        format.html { redirect_to event_cortejo_path(@event), alert: @procession_step.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    @procession_step.update(step_params)
    head :no_content
  end

  def destroy
    @procession_step.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@procession_step)) }
      format.html { redirect_to event_cortejo_path(@event) }
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_step
    @procession_step = @event.procession_steps.find(params[:id])
  end

  def step_params
    params.require(:procession_step).permit(:description, :kind)
  end
end
