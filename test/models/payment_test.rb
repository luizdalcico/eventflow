require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
  end

  def valid_attributes
    { payer_name: "Maria Silva", amount: 1500.50, reference: "Entrada",
      payment_method: "pix", paid_on: Date.current }
  end

  test "is valid with all required attributes" do
    payment = @event.payments.new(valid_attributes)
    assert payment.valid?
  end

  test "requires a payer name" do
    payment = @event.payments.new(valid_attributes.merge(payer_name: ""))
    assert_not payment.valid?
    assert payment.errors[:payer_name].present?
  end

  test "requires a positive amount" do
    payment = @event.payments.new(valid_attributes.merge(amount: 0))
    assert_not payment.valid?

    payment = @event.payments.new(valid_attributes.merge(amount: -10))
    assert_not payment.valid?
  end

  test "requires a paid_on date" do
    payment = @event.payments.new(valid_attributes.merge(paid_on: nil))
    assert_not payment.valid?
  end

  test "rejects an unknown payment method" do
    payment = @event.payments.new(valid_attributes.merge(payment_method: "bitcoin"))
    assert_not payment.valid?
    assert payment.errors[:payment_method].present?
  end

  test "accepts every whitelisted payment method" do
    Payment::PAYMENT_METHODS.each do |method|
      payment = @event.payments.new(valid_attributes.merge(payment_method: method))
      assert payment.valid?, "expected #{method} to be valid"
    end
  end

  test "recent_first orders by paid_on descending" do
    older = @event.payments.create!(valid_attributes.merge(paid_on: Date.current - 5))
    newer = @event.payments.create!(valid_attributes.merge(paid_on: Date.current))

    assert_equal [ newer, older ], @event.payments.recent_first.to_a
  end

  test "parse_brl is inherited from ApplicationRecord" do
    assert_equal BigDecimal("1234.56"), Payment.parse_brl("R$ 1.234,56")
    assert_nil Payment.parse_brl(nil)
    assert_equal BigDecimal("10"), Payment.parse_brl(10)
  end
end
