class PaymentsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_event
  before_action :set_payment, only: %i[destroy receipt]

  def index
    @payments = @event.payments.recent_first
    @payment = @event.payments.new(paid_on: Date.current)
  end

  def create
    @payment = @event.payments.new(payment_params)
    if @payment.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("payments_empty"),
            turbo_stream.prepend("payments", partial: "payments/payment", locals: { event: @event, payment: @payment }),
            turbo_stream.replace("add_payment", partial: "payments/add_form", locals: { event: @event, payment: @event.payments.new(paid_on: Date.current) }),
            turbo_stream.replace("payments_totals", partial: "payments/totals", locals: { event: @event })
          ]
        end
        format.html { redirect_to event_payments_path(@event), notice: "Pagamento registrado." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "add_payment",
            partial: "payments/add_form",
            locals: { event: @event, payment: @payment }
          ), status: :unprocessable_entity
        end
        format.html { redirect_to event_payments_path(@event), alert: @payment.errors.full_messages.to_sentence }
      end
    end
  end

  def destroy
    @payment.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(dom_id(@payment)),
          turbo_stream.replace("payments_totals", partial: "payments/totals", locals: { event: @event })
        ]
      end
      format.html { redirect_to event_payments_path(@event), notice: "Pagamento removido." }
    end
  end

  def receipt
    send_data TemplateService.generate_receipt(@payment),
              filename: "recibo_#{@payment.id}_#{Date.current.strftime('%Y%m%d')}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_payment
    @payment = @event.payments.find(params[:id])
  end

  # Strong params; the BRL-formatted amount is parsed into a decimal.
  def payment_params
    permitted = params.require(:payment).permit(:payer_name, :amount, :reference, :payment_method, :paid_on)
    permitted[:amount] = Payment.parse_brl(permitted[:amount]) if permitted.key?(:amount)
    permitted
  end
end
