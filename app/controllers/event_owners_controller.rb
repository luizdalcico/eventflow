class EventOwnersController < ApplicationController
  # Identity fields reused when prefilling from an existing CPF.
  # Excludes role (event-specific) and cpf (already typed by the user).
  REUSABLE_FIELDS = %w[name email phone_number address mother_name father_name birth_date instagram].freeze

  before_action :set_event
  before_action :set_event_owner, only: [ :show, :edit, :update, :destroy ]

  def index
    @event_owners = @event.event_owners.order(:name)
  end

  # Looks up an existing responsible person by CPF so their reusable identity
  # fields can prefill the form. Returns the latest match across all events.
  def lookup
    owner = EventOwner.find_reusable_by_cpf(params[:cpf])

    if owner
      render json: { found: true, owner: owner.slice(*REUSABLE_FIELDS) }
    else
      render json: { found: false }
    end
  end

  def show
  end

  def new
    @event_owner = @event.event_owners.build
  end

  def create
    @event_owner = @event.event_owners.build(event_owner_params)

    if @event_owner.save
      redirect_to [ @event, @event_owner ], notice: "Responsável adicionado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event_owner.update(event_owner_params)
      redirect_to [ @event, @event_owner ], notice: "Responsável atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event_owner.destroy!
    redirect_to event_event_owners_path(@event), notice: "Responsável removido com sucesso!"
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_event_owner
    @event_owner = @event.event_owners.find(params[:id])
  end

  def event_owner_params
    params.require(:event_owner).permit(:name, :email, :cpf, :phone_number, :role,
                                        :address, :mother_name, :father_name, :birth_date, :instagram)
  end
end
