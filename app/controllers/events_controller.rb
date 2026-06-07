class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @upcoming_events = Event.includes(:event_owners).upcoming.order(:main_date)
    @past_events = Event.includes(:event_owners).past.order(main_date: :desc)
  end

  def show
    @event_owners = @event.event_owners
    @event_dates = @event.event_dates.order(:date)
    @guests = @event.guests.order(:name)
    @godparents = @event.godparents.order(:name)
    @providers = @event.providers.includes(:event_providers)
    @manager_tasks = @event.manager_checklists.order(:due_date)
    @owner_tasks = @event.owner_checklists.order(:due_date)

    respond_to do |format|
      format.html
      format.pdf do
        pdf_content = TemplateService.generate_event_report(@event, :pdf)
        send_data pdf_content, 
                  filename: "evento_#{@event.id}_#{Date.current.strftime('%Y%m%d')}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end

  def new
    @event = Event.new
    @event.event_owners.build
  end

  def create
    @event = Event.new(event_params)
    
    if @event.save
      redirect_to @event, notice: 'Evento criado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Evento atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy!
    redirect_to events_path, notice: 'Evento removido com sucesso!'
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :title, :event_type, :main_date, :start_time, :end_time, :place, :address, 
      :estimated_guests, :extra_hours,
      event_owners_attributes: [:id, :name, :email, :cpf, :phone_number, :role, :_destroy]
    )
  end
end
