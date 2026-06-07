class EventOwner < ApplicationRecord
  belongs_to :event

  validates :name, presence: true
  validates :phone_number, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "deve ser um email válido" }
  validates :cpf, format: { with: /\A\d{11}\z/, message: "deve conter 11 dígitos" }, allow_blank: true

  before_validation :sanitize_phone_number, :sanitize_cpf

  scope :by_role, ->(role) { where(role: role) }

  private

  def sanitize_phone_number
    self.phone_number = phone_number.gsub(/\D/, "") if phone_number.present?
  end

  def sanitize_cpf
    self.cpf = cpf.gsub(/\D/, "") if cpf.present?
  end
end
