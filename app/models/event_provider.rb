class EventProvider < ApplicationRecord
  # Operational/financial status of a provider for a given event.
  STATUSES = %w[pendente orcado contratado pago].freeze

  belongs_to :event
  belongs_to :provider

  validates :event_id, uniqueness: { scope: :provider_id }
  validates :status, inclusion: { in: STATUSES }
  validates :professionals_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Parse a Brazilian-formatted money string ("R$ 1.234,56") into a BigDecimal.
  # Returns nil when blank or unparseable, and passes numerics straight through.
  def self.parse_brl(raw)
    return nil if raw.nil?
    return raw if raw.is_a?(Numeric)

    digits = raw.to_s.gsub(/[^\d,.-]/, "").tr(".", "").tr(",", ".")
    return nil if digits.blank?

    BigDecimal(digits)
  rescue ArgumentError
    nil
  end

  def custom_detail(key)
    custom_details&.dig(key.to_s)
  end

  def set_custom_detail(key, value)
    self.custom_details ||= {}
    self.custom_details[key.to_s] = value
  end
end
