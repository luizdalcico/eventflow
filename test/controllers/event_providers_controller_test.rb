require "test_helper"

class EventProvidersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
    @provider = Provider.create!(provider_type: "photographer", name: "Foto & Arte",
                                 contact_name: "Paulo", phone_number: "85999990000",
                                 document: "12345678000190")
  end

  test "index renders associated providers as a table with type, name and contact" do
    @event.event_providers.create!(provider: @provider)

    get event_event_providers_url(@event)
    assert_response :success

    assert_select "table"
    assert_select "th", text: "Tipo"
    assert_select "th", text: "Fornecedor"
    assert_select "th", text: "Contato"
    assert_select "th", text: "Status"
    assert_select "th", text: "Profissionais"
    assert_select "th", text: "Valor"
    assert_select "th", text: "Valor pago"
    assert_select "th", text: "Observações"

    assert_select "tbody#event_providers tr", count: 1
    assert_select "tbody#event_providers tr td", text: /Fotógrafo/
    assert_select "tbody#event_providers tr td a", text: "Foto & Arte"
    assert_select "tbody#event_providers tr td", text: /Paulo/
  end

  test "index shows the empty state when no provider is associated" do
    get event_event_providers_url(@event)
    assert_response :success
    assert_select "#event_providers_empty"
  end

  test "create associates a provider to the event" do
    assert_difference("@event.event_providers.count", 1) do
      post event_event_providers_url(@event), params: { provider_id: @provider.id }
    end
    assert_redirected_to event_event_providers_url(@event)
  end

  test "update_details persists value, paid_value, status and professionals into columns and notes into custom_details" do
    ep = @event.event_providers.create!(provider: @provider)

    patch update_details_event_event_provider_url(@event, ep),
          params: { event_provider: { value: "R$ 5.000,00", paid_value: "R$ 2.000,00", status: "contratado", professionals_count: "3", notes: "Pago 40%" } }
    assert_response :no_content

    ep.reload
    assert_equal BigDecimal("5000.00"), ep.value
    assert_equal BigDecimal("2000.00"), ep.paid_value
    assert_equal "contratado", ep.status
    assert_equal 3, ep.professionals_count
    assert_equal "Pago 40%", ep.custom_detail("notes")
  end

  test "update_details stores a blank professionals_count as nil" do
    ep = @event.event_providers.create!(provider: @provider, professionals_count: 4)

    patch update_details_event_event_provider_url(@event, ep),
          params: { event_provider: { professionals_count: "" } }
    assert_response :no_content

    assert_nil ep.reload.professionals_count
  end

  test "export returns an xlsx attachment" do
    @event.event_providers.create!(provider: @provider, value: 1000, status: "pago")

    get export_event_event_providers_url(@event, format: :xlsx)
    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.media_type
    assert response.body.bytesize.positive?
  end

  test "index renders the totals footer" do
    @event.event_providers.create!(provider: @provider, value: 1000, status: "pago", professionals_count: 2)

    get event_event_providers_url(@event)
    assert_response :success
    assert_select "#providers_totals"
  end

  test "destroy removes the association" do
    ep = @event.event_providers.create!(provider: @provider)
    assert_difference("@event.event_providers.count", -1) do
      delete event_event_provider_url(@event, ep)
    end
    assert_redirected_to event_event_providers_url(@event)
  end
end
