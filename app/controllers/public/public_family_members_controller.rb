module Public
  # Página pública: familiares se cadastram na lista do evento (linha plana).
  class PublicFamilyMembersController < BaseController
    include ActionView::RecordIdentifier

    before_action :require_editable!
    before_action :set_member, only: %i[update destroy]

    def create
      next_position = (@event.family_members.maximum(:position) || 0) + 1
      @family_member = @event.family_members.new(member_params.merge(position: next_position))

      if @family_member.save
        respond_to do |format|
          format.turbo_stream # create.turbo_stream.erb
          format.html { redirect_to family_member_list_path(@list.token) }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "new_public_family_member",
              partial: "public/family_member_lists/form",
              locals: { list: @list, family_member: @family_member }
            )
          end
          format.html { redirect_to family_member_list_path(@list.token), alert: @family_member.errors.full_messages.to_sentence }
        end
      end
    end

    def update
      @family_member.update!(member_params)
      head :no_content
    end

    def destroy
      @family_member.destroy!
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@family_member)) }
        format.html { redirect_to family_member_list_path(@list.token) }
      end
    end

    private

    def find_list(token)
      FamilyMemberList.find_by(token: token)
    end

    def editable_redirect_path
      family_member_list_path(@list.token)
    end

    def set_member
      @family_member = @event.family_members.find(params[:id])
    end

    def member_params
      params.require(:family_member).permit(:name, :role, :notes)
    end
  end
end
