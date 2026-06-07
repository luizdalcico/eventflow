module Public
  class BaseController < ApplicationController
    layout "public"

    before_action :set_list

    private

    def set_list
      @list = find_list(params[:token])
      @event = @list&.event

      if @list.nil?
        render "public/shared/invalid", status: :not_found
      elsif @list.expired?
        render "public/shared/expired", status: :gone
      end
    end

    # Each public list controller resolves its own token-protected record.
    # Subclasses override with their own model.
    def find_list(token)
      raise NotImplementedError
    end

    # Bloqueia escrita quando o link não está mais editável (expirado ou finalizado).
    # Subclasses informam para onde redirecionar no formato HTML.
    def require_editable!
      return if @list.editable?

      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { redirect_to editable_redirect_path }
      end
    end

    def editable_redirect_path
      raise NotImplementedError
    end
  end
end
