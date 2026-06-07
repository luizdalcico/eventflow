class Payment < ApplicationRecord
  # Accepted payment methods, mirrored by ApplicationHelper::PAYMENT_METHOD_LABELS.
  PAYMENT_METHODS = %w[pix dinheiro cartao transferencia cheque boleto].freeze

  belongs_to :event

  validates :payer_name, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }
  validates :paid_on, presence: true

  # Most recent payment first, used for the event history listing.
  scope :recent_first, -> { order(paid_on: :desc, id: :desc) }
end
