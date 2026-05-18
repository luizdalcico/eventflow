class EventOwnersController < ApplicationController
  before_action :set_event
  before_action :set_event_owner, only: [:show, :edit, :update, :destroy]

  def index
    @event_owners = @event.event_owners.order(:name)
  end

  def show
  end

  def new
    @event_owner = @event.event_owners.build
  end

  def create
    @event_owner = @event.event_owners.build(event_owner_params)
    
    if @event_owner.save
      redirect_to [@event, @event_owner], notice: 'Responsável adicionado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event_owner.update(event_owner_params)
      redirect_to [@event, @event_owner], notice: 'Responsável atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event_owner.destroy!
    redirect_to event_event_owners_path(@event), notice: 'Responsável removido com sucesso!'
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_event_owner
    @event_owner = @event.event_owners.find(params[:id])
  end

  def event_owner_params
    params.require(:event_owner).permit(:name, :email, :cpf, :phone_number, :role)
  end
end