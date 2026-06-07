class CortejoController < ApplicationController
  before_action :set_event

  def show
    @procession_steps = @event.procession_steps.ordered
    @procession_step = @event.procession_steps.new
    @family_members = @event.family_members.ordered
    @family_member = @event.family_members.new
    @godparents = @event.godparents.ordered
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end
end
