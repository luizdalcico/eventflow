class EventProvider < ApplicationRecord
  # Operational/financial status of a provider for a given event.
  STATUSES = %w[pendente orcado contratado pago].freeze

  belongs_to :event
  belongs_to :provider
  has_many :pendencies, dependent: :nullify

  validates :event_id, uniqueness: { scope: :provider_id }
  validates :status, inclusion: { in: STATUSES }
  validates :professionals_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :paid_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def custom_detail(key)
    custom_details&.dig(key.to_s)
  end

  def set_custom_detail(key, value)
    self.custom_details ||= {}
    self.custom_details[key.to_s] = value
  end
end
