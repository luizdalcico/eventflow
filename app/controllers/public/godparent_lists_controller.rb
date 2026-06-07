module Public
  class GodparentListsController < BaseController
    before_action :require_editable!, only: %i[finalize draft]

    def show
      # Sempre deixa pelo menos uma linha em branco para preencher.
      @list.add_pair! if @list.editable? && @list.anchors.none?
      @anchors = @list.anchors
    end

    # "Salvar rascunho": o auto-save já persiste; aqui só damos um retorno visual.
    def draft
      redirect_to godparent_list_path(@list.token), notice: "Rascunho salvo! As alterações já são salvas automaticamente."
    end

    def finalize
      incomplete = @list.incomplete_anchors
      if incomplete.any?
        positions = incomplete.map(&:position).sort.uniq.join(", ")
        redirect_to godparent_list_path(@list.token),
                    alert: "Preencha todos os campos de cada par antes de finalizar. Incompletos: par(es) #{positions}."
        return
      end

      @list.finalize!
      # Recarrega a página em todos os navegadores conectados (trava a edição para todos).
      Turbo::StreamsChannel.broadcast_refresh_to(@list)
      redirect_to godparent_list_path(@list.token), notice: "Lista finalizada! O cerimonial foi avisado."
    end
  end
end
