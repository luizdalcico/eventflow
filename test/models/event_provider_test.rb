require "test_helper"

class EventProviderTest < ActiveSupport::TestCase
  def setup
    @event = events(:future_event)
    @provider = Provider.create!(
      provider_type: "photographer",
      name: "Photo Studio",
      document: "11.111.111/0001-11",
      contact_name: "Jane Doe",
      phone_number: "(11) 88888-8888"
    )
  end

  def build_event_provider(attrs = {})
    EventProvider.new({ event: @event, provider: @provider }.merge(attrs))
  end

  test "is valid with defaults" do
    ep = build_event_provider
    assert ep.valid?
    assert_equal "pendente", ep.status
    assert_nil ep.professionals_count
    assert_nil ep.paid_value
  end

  test "accepts every defined status" do
    EventProvider::STATUSES.each do |status|
      assert build_event_provider(status: status).valid?, "#{status} should be valid"
    end
  end

  test "rejects an unknown status" do
    ep = build_event_provider(status: "cancelado")
    assert_not ep.valid?
    assert ep.errors[:status].any?
  end

  test "rejects a negative professionals_count" do
    ep = build_event_provider(professionals_count: -1)
    assert_not ep.valid?
  end

  test "allows a blank professionals_count (e.g. a buffet team)" do
    assert build_event_provider(professionals_count: nil).valid?
  end

  test "rejects a negative value" do
    ep = build_event_provider(value: -10)
    assert_not ep.valid?
  end

  test "allows a nil value" do
    assert build_event_provider(value: nil).valid?
  end

  test "rejects a negative paid_value" do
    ep = build_event_provider(paid_value: -10)
    assert_not ep.valid?
  end

  test "allows a nil paid_value" do
    assert build_event_provider(paid_value: nil).valid?
  end

  test "round-trips notes through custom_details" do
    ep = build_event_provider
    ep.set_custom_detail(:notes, "Chega às 14h")
    ep.save!
    assert_equal "Chega às 14h", ep.reload.custom_detail(:notes)
  end

  test "parse_brl handles formatted, plain, numeric and blank input" do
    assert_equal BigDecimal("1234.56"), EventProvider.parse_brl("R$ 1.234,56")
    assert_equal BigDecimal("1500"), EventProvider.parse_brl("1500")
    assert_equal 99.5, EventProvider.parse_brl(99.5)
    assert_nil EventProvider.parse_brl("")
    assert_nil EventProvider.parse_brl(nil)
    assert_nil EventProvider.parse_brl("abc")
  end
end
