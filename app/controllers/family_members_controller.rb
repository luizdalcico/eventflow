class FamilyMembersController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_event
  before_action :set_member, only: %i[update destroy]

  def create
    next_position = (@event.family_members.maximum(:position) || 0) + 1
    @family_member = @event.family_members.new(member_params.merge(position: next_position))
    if @family_member.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("family_members_empty"),
            turbo_stream.append("family_members", partial: "family_members/family_member", locals: { event: @event, family_member: @family_member }),
            turbo_stream.replace("new_family_member", partial: "family_members/form", locals: { event: @event, family_member: @event.family_members.new })
          ]
        end
        format.html { redirect_to event_guests_path(@event) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_family_member", partial: "family_members/form", locals: { event: @event, family_member: @family_member }) }
        format.html { redirect_to event_guests_path(@event), alert: @family_member.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    @family_member.update(member_params)
    head :no_content
  end

  def destroy
    @family_member.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@family_member)) }
      format.html { redirect_to event_guests_path(@event) }
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_member
    @family_member = @event.family_members.find(params[:id])
  end

  def member_params
    params.require(:family_member).permit(:name, :role, :notes)
  end
end
