# Ações compartilhadas pelos checklists (interno e dos responsáveis).
# Cada controller define: model_class, collection_name, param_key, checklist_title.
module ChecklistActions
  extend ActiveSupport::Concern
  include ActionView::RecordIdentifier

  included do
    before_action :set_event
    before_action :set_item, only: %i[update destroy]
  end

  def index
    @title = checklist_title
    @items = collection.order(:completed, Arel.sql("due_date IS NULL, due_date"))
    @item = collection.new
  end

  def create
    @item = collection.new(item_params)
    if @item.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("checklist_empty"),
            turbo_stream.append("checklist_items", partial: "shared/checklist_item", locals: { event: @event, item: @item }),
            turbo_stream.replace("new_checklist", partial: "shared/checklist_form", locals: { event: @event, item: collection.new })
          ]
        end
        format.html { redirect_to index_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_checklist", partial: "shared/checklist_form", locals: { event: @event, item: @item }) }
        format.html { redirect_to index_path, alert: @item.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    @item.update(item_params)
    head :no_content
  end

  def destroy
    @item.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@item)) }
      format.html { redirect_to index_path }
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_item
    @item = collection.find(params[:id])
  end

  def collection
    @event.public_send(collection_name)
  end

  def item_params
    params.require(param_key).permit(:task, :due_date, :completed)
  end

  def index_path
    polymorphic_path([@event, model_class])
  end
end
