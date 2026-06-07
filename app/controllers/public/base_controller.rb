module Public
  class BaseController < ApplicationController
    layout "public"

    before_action :set_list

    private

    def set_list
      @list = GodparentList.find_by(token: params[:token])
      @event = @list&.event

      if @list.nil?
        render "public/godparent_lists/invalid", status: :not_found
      elsif @list.expired?
        render "public/godparent_lists/expired", status: :gone
      end
    end

    # Bloqueia escrita quando o link não está mais editável (expirado ou finalizado).
    def require_editable!
      return if @list.editable?

      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { redirect_to godparent_list_path(@list.token) }
      end
    end
  end
end
