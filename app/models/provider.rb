class Provider < ApplicationRecord
  PROVIDER_TYPES = %w[
    photographer buffet filming cake sweets chocolates drinks beer light decoration
    bouquet women_cloth men_cloth beauty_shop souvenir invitations music_band
  ].freeze

  has_many :event_providers, dependent: :destroy
  has_many :events, through: :event_providers

  validates :provider_type, presence: true, inclusion: { in: PROVIDER_TYPES }
  validates :name, presence: true
  validates :contact_name, presence: true
  validates :phone_number, presence: true
  validates :document, format: { with: /\A(\d{11}|\d{14})\z/, message: 'deve conter 11 dígitos (CPF) ou 14 dígitos (CNPJ)' }, allow_blank: true

  before_validation :sanitize_phone_number, :sanitize_document

  scope :by_type, ->(type) { where(provider_type: type) }

  private

  def sanitize_phone_number
    self.phone_number = phone_number.gsub(/\D/, '') if phone_number.present?
  end

  def sanitize_document
    self.document = document.gsub(/\D/, '') if document.present?
  end
end
