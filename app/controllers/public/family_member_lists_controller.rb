module Public
  class FamilyMemberListsController < BaseController
    before_action :require_editable!, only: %i[finalize]

    def show
      @family_members = @event.family_members.ordered
      @family_member = @event.family_members.new
    end

    def finalize
      @list.finalize!
      # Recarrega a página em todos os navegadores conectados (trava a edição para todos).
      Turbo::StreamsChannel.broadcast_refresh_to(@list)
      redirect_to family_member_list_path(@list.token), notice: "Lista finalizada! O cerimonial foi avisado."
    end

    private

    def find_list(token)
      FamilyMemberList.find_by(token: token)
    end

    def editable_redirect_path
      family_member_list_path(@list.token)
    end
  end
end
