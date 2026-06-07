require "test_helper"

class TemplateServiceTest < ActiveSupport::TestCase
  def setup
    @event = Event.create!(
      title: "Casamento Contrato",
      event_type: "wedding",
      main_date: Date.new(2026, 9, 12),
      start_time: "14:00",
      end_time: "20:00",
      place: "Salão Jardim",
      estimated_guests: 100,
      extra_hours: 2,
      contract_total_value: 12_345.67,
      contract_extra_hour_rate: 250.0,
      contract_payment_due_date: Date.new(2026, 8, 1),
      contract_receptionists_count: 4
    )
    @event.event_owners.create!(
      name: "Maria Silva", cpf: "12345678901",
      phone_number: "11999999999", email: "maria@example.com"
    )
    provider = Provider.create!(provider_type: "buffet", name: "Buffet A",
                                document: "11111111000111", contact_name: "Ana",
                                phone_number: "11999990000")
    @event.event_providers.create!(provider: provider, value: 1500, status: "pago", professionals_count: 4)
  end

  test "generate_contract returns a non-empty PDF byte string" do
    pdf = TemplateService.generate_contract(@event, :pdf)

    assert pdf.is_a?(String)
    assert_operator pdf.bytesize, :>, 0
    assert_equal "%PDF-", pdf[0, 5]
  end

  test "generate_contract works without contract values" do
    bare = Event.create!(
      title: "Sem Valores", event_type: "adult_birthday",
      main_date: Date.new(2026, 9, 12), estimated_guests: 50
    )

    pdf = TemplateService.generate_contract(bare, :pdf)

    assert_equal "%PDF-", pdf[0, 5]
  end

  test "generate_contract raises on unsupported format" do
    assert_raises(ArgumentError) { TemplateService.generate_contract(@event, :xls) }
  end

  test "format_currency formats decimals as Brazilian Real" do
    assert_equal "R$ 12.345,67", TemplateService.send(:format_currency, 12_345.67)
    assert_equal "R$ 250,00", TemplateService.send(:format_currency, 250)
    assert_equal "—", TemplateService.send(:format_currency, nil)
  end

  test "format_cpf masks 11 digits" do
    assert_equal "123.456.789-01", TemplateService.send(:format_cpf, "12345678901")
    assert_equal "—", TemplateService.send(:format_cpf, "123")
    assert_equal "—", TemplateService.send(:format_cpf, nil)
  end

  test "generates a non-empty pdf report" do
    bytes = TemplateService.generate_event_report(@event, :pdf)
    assert bytes.bytesize.positive?
    assert bytes.start_with?("%PDF")
  end

  test "generates a non-empty xlsx cost sheet" do
    bytes = TemplateService.generate_event_report(@event, :xlsx)
    assert bytes.bytesize.positive?
    # XLSX files are zip archives — they start with the PK signature.
    assert_equal "PK".b, bytes[0, 2].b
  end

  test "cortejo and family sections add content to the PDF report" do
    baseline = TemplateService.generate_event_report(@event, :pdf).bytesize

    @event.procession_steps.create!(description: "Entrada da noiva", kind: "entrada", position: 1)
    @event.family_members.create!(name: "Dona Maria", role: "mae_noiva", position: 1)

    with_data = TemplateService.generate_event_report(@event, :pdf).bytesize
    assert with_data > baseline
  end

  test "generate_event_report raises for an unsupported format" do
    assert_raises(ArgumentError) do
      TemplateService.generate_event_report(@event, :csv)
    end
  end
end
