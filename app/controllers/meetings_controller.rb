class MeetingsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_event
  before_action :set_meeting, only: %i[show update destroy]

  def index
    @meetings = @event.meetings.ordered.includes(:pendencies)
    @meeting = @event.meetings.new
    @general_pendencies = @event.pendencies.where(meeting_id: nil).includes(:event_provider).ordered
    @pendency = @event.pendencies.new
  end

  def show
    @pendencies = @meeting.pendencies.includes(:event_provider).ordered
    @pendency = @event.pendencies.new(meeting: @meeting)
  end

  def create
    @meeting = @event.meetings.new(meeting_params)
    if @meeting.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("meetings_empty"),
            turbo_stream.append("meetings", partial: "meetings/meeting", locals: { event: @event, meeting: @meeting }),
            turbo_stream.replace("new_meeting", partial: "meetings/form", locals: { event: @event, meeting: @event.meetings.new })
          ]
        end
        format.html { redirect_to event_meetings_path(@event) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_meeting", partial: "meetings/form", locals: { event: @event, meeting: @meeting }) }
        format.html { redirect_to event_meetings_path(@event), alert: @meeting.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    @meeting.update(meeting_params)
    head :no_content
  end

  def destroy
    @meeting.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@meeting)) }
      format.html { redirect_to event_meetings_path(@event) }
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_meeting
    @meeting = @event.meetings.find(params[:id])
  end

  def meeting_params
    params.require(:meeting).permit(:date, :participants, :summary)
  end
end
