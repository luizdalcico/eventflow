class EventsController < ApplicationController
  before_action :set_event, only: [ :show, :edit, :update, :destroy, :contract ]

  FILTERS = %w[upcoming past all].freeze

  def index
    @query = params[:q]
    @period = params[:period]
    @filter = params[:filter].presence_in(FILTERS) || "upcoming"

    base = Event.includes(:event_owners).search(@query).in_date_range(@period)
    @filters_active = @query.present? || @period.present?

    # Summary cards count the whole (search/period-filtered) dataset, regardless
    # of which time segment the active card filter is currently showing.
    @upcoming_count = base.upcoming.count
    @past_count = base.past.count
    @total_count = @upcoming_count + @past_count

    @upcoming_events = base.upcoming.order(:main_date) if show_upcoming?
    @past_events = base.past.order(main_date: :desc) if show_past?
  end

  def show
    @event_owners = @event.event_owners
    @event_dates = @event.event_dates.order(:date)
    @guests = @event.guests.order(:name)
    @procession_steps_count = @event.procession_steps.count
    @providers = @event.providers.includes(:event_providers)
    @manager_tasks = @event.manager_checklists.order(:due_date)
    @owner_tasks = @event.owner_checklists.order(:due_date)

    respond_to do |format|
      format.html
      format.pdf do
        pdf_content = TemplateService.generate_event_report(@event, :pdf)
        send_data pdf_content,
                  filename: "evento_#{@event.id}_#{Date.current.strftime('%Y%m%d')}.pdf",
                  type: "application/pdf",
                  disposition: "attachment"
      end
    end
  end

  def contract
    unless @event.contract_ready?
      missing = @event.missing_contract_fields.to_sentence
      redirect_to @event, alert: "Não foi possível gerar o contrato. Preencha: #{missing}."
      return
    end

    pdf_content = TemplateService.generate_contract(@event, :pdf)
    send_data pdf_content,
              filename: "contrato_#{@event.id}_#{Date.current.strftime('%Y%m%d')}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end

  def new
    @event = Event.new
    @event.event_owners.build
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to @event, notice: "Evento criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Evento atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy!
    redirect_to events_path, notice: "Evento removido com sucesso!"
  end

  private

  def show_upcoming?
    @filter.in?(%w[upcoming all])
  end
  helper_method :show_upcoming?

  def show_past?
    @filter.in?(%w[past all])
  end
  helper_method :show_past?

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :title, :event_type, :main_date, :start_time, :end_time, :place, :address,
      :estimated_guests, :extra_hours,
      :contract_total_value, :contract_extra_hour_rate, :contract_payment_due_date, :contract_receptionists_count,
      event_owners_attributes: [ :id, :name, :email, :cpf, :phone_number, :role, :_destroy ]
    )
  end
end
