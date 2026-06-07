module Public
  # Um "par" = dois Godparents (madrinha + padrinho) ligados por pair_id.
  # A madrinha é a âncora do par (params[:id] = madrinha.id).
  class GodparentPairsController < BaseController
    before_action :require_editable!

    def create
      @madrinha = @list.add_pair!

      respond_to do |format|
        format.turbo_stream # create.turbo_stream.erb (append da linha)
        format.html { redirect_to godparent_list_path(@list.token) }
      end
    end

    def update
      madrinha = pair_anchor
      padrinho = madrinha.pair

      Godparent.transaction do
        madrinha.update!(member_attrs(:madrinha).merge(pair_attrs))
        padrinho&.update!(member_attrs(:padrinho).merge(pair_attrs))
      end

      head :ok
    end

    def destroy
      madrinha = pair_anchor
      padrinho = madrinha.pair

      Godparent.transaction do
        # Desfaz o vínculo mútuo antes de apagar (evita violar a FK self-referencial).
        madrinha.update_columns(pair_id: nil)
        padrinho&.update_columns(pair_id: nil)
        padrinho&.destroy!
        madrinha.destroy!
      end

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove("pair_#{madrinha.id}") }
        format.html { redirect_to godparent_list_path(@list.token) }
      end
    end

    private

    def pair_anchor
      @list.event.godparents.find(params[:id])
    end

    # Atributos por pessoa: nome, telefone e relação com o casal.
    def member_attrs(role)
      member = pair_params.fetch(role, ActionController::Parameters.new)
      {
        name: member[:name],
        phone_number: member[:phone_number]&.gsub(/\D/, ""),
        relation: member[:relation].presence_in(Godparent::PERSON_RELATIONS)
      }
    end

    # Atributos do par, gravados de forma idêntica nas duas linhas (lado + relação).
    def pair_attrs
      {
        side: pair_params[:side].presence_in(Godparent::SIDE_VALUES),
        relationship: pair_params[:relationship].presence_in(Godparent::RELATIONSHIPS)
      }
    end

    def pair_params
      params.fetch(:pair, ActionController::Parameters.new)
    end
  end
end
