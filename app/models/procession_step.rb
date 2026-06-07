class ProcessionStep < ApplicationRecord
  # Momentos do cortejo / da cerimônia, em ordem.
  KINDS = %w[entrada leitura salmo aliancas saida outro].freeze

  belongs_to :event

  validates :description, presence: true
  validates :kind, inclusion: { in: KINDS }, allow_blank: true

  scope :ordered, -> { order(:position, :id) }
end
