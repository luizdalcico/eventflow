class ProvidersController < ApplicationController
  before_action :set_provider, only: [ :show, :edit, :update, :destroy ]

  def index
    @query = params[:q]
    @type = params[:type].presence_in(Provider::PROVIDER_TYPES)
    @filters_active = @query.present? || @type.present?

    providers = Provider.search(@query)
    providers = providers.by_type(@type) if @type
    @providers = providers.order(:provider_type, :name)
  end

  def show
    @events = @provider.events.includes(:event_owners).order(:main_date)
  end

  def new
    @provider = Provider.new
  end

  def create
    @provider = Provider.new(provider_params)

    if @provider.save
      redirect_to @provider, notice: "Fornecedor criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @provider.update(provider_params)
      redirect_to @provider, notice: "Fornecedor atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @provider.destroy!
    redirect_to providers_path, notice: "Fornecedor removido com sucesso!"
  end

  private

  def set_provider
    @provider = Provider.find(params[:id])
  end

  def provider_params
    params.require(:provider).permit(:provider_type, :name, :document, :contact_name, :phone_number)
  end
end
