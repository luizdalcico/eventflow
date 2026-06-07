require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100,
                           contract_total_value: 5000)
  end

  def valid_params
    { payer_name: "Maria Silva", amount: "R$ 1.500,00", reference: "Entrada",
      payment_method: "pix", paid_on: Date.current.to_s }
  end

  test "index renders the payments table with the expected columns" do
    @event.payments.create!(payer_name: "Maria", amount: 1500, payment_method: "pix", paid_on: Date.current)

    get event_payments_url(@event)
    assert_response :success

    assert_select "table"
    assert_select "th", text: "Recebido de"
    assert_select "th", text: "Valor"
    assert_select "th", text: "Referente à"
    assert_select "th", text: "Forma"
    assert_select "th", text: "Data"
    assert_select "tbody#payments tr", count: 1
    assert_select "tbody#payments tr td", text: /Maria/
  end

  test "index shows the empty state when there are no payments" do
    get event_payments_url(@event)
    assert_response :success
    assert_select "#payments_empty"
  end

  test "index shows the automatic balance against the contract" do
    @event.payments.create!(payer_name: "Maria", amount: 2000, payment_method: "pix", paid_on: Date.current)

    get event_payments_url(@event)
    assert_response :success
    # Restando = 5000 - 2000
    assert_select "#payments_totals", text: /R\$ 3\.000,00/
  end

  test "create persists a payment parsing the BRL amount" do
    assert_difference("@event.payments.count", 1) do
      post event_payments_url(@event), params: { payment: valid_params }
    end

    payment = @event.payments.order(:id).last
    assert_equal "Maria Silva", payment.payer_name
    assert_equal BigDecimal("1500.00"), payment.amount
    assert_equal "Entrada", payment.reference
    assert_equal "pix", payment.payment_method
  end

  test "create with turbo_stream refreshes the totals and appends the row" do
    post event_payments_url(@event), params: { payment: valid_params },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_match "payments_totals", response.body
  end

  test "create with invalid data does not persist and re-renders the form" do
    assert_no_difference("@event.payments.count") do
      post event_payments_url(@event),
           params: { payment: valid_params.merge(payer_name: "") },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    assert_response :unprocessable_entity
    assert_match "add_payment", response.body
  end

  test "destroy removes the payment" do
    payment = @event.payments.create!(payer_name: "Maria", amount: 1500, payment_method: "pix", paid_on: Date.current)

    assert_difference("@event.payments.count", -1) do
      delete event_payment_url(@event, payment)
    end
    assert_redirected_to event_payments_url(@event)
  end

  test "receipt returns a PDF attachment" do
    payment = @event.payments.create!(payer_name: "Maria", amount: 1500, payment_method: "pix", paid_on: Date.current)

    get receipt_event_payment_url(@event, payment, format: :pdf)
    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_match(/attachment/, response.headers["Content-Disposition"])
    assert response.body.start_with?("%PDF")
  end
end
