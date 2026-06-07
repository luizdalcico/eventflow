class CortejoController < ApplicationController
  before_action :set_event

  def show
    @procession_steps = @event.procession_steps.ordered
    @procession_step = @event.procession_steps.new
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end
end
