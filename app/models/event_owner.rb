class EventOwner < ApplicationRecord
  belongs_to :event

  validates :name, presence: true
  validates :phone_number, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "deve ser um email válido" }
  validates :cpf, format: { with: /\A\d{11}\z/, message: "deve conter 11 dígitos" }, allow_blank: true

  before_validation :sanitize_phone_number, :sanitize_cpf, :sanitize_instagram

  scope :by_role, ->(role) { where(role: role) }
  scope :by_cpf, ->(cpf) { where(cpf: cpf) }

  # Looks up a reusable responsible person by CPF across every event.
  # Sanitizes the raw (possibly masked) input and only queries on a full
  # 11-digit CPF — returns the most recently created match, or nil.
  def self.find_reusable_by_cpf(raw)
    digits = raw.to_s.gsub(/\D/, "")
    return nil unless digits.length == 11

    by_cpf(digits).order(created_at: :desc).first
  end

  private

  def sanitize_phone_number
    self.phone_number = phone_number.gsub(/\D/, "") if phone_number.present?
  end

  def sanitize_cpf
    self.cpf = cpf.gsub(/\D/, "") if cpf.present?
  end

  # Store the Instagram handle canonically: no leading @, no surrounding whitespace.
  def sanitize_instagram
    self.instagram = instagram.strip.delete_prefix("@") if instagram.present?
  end
end
