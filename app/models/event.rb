class Event < ApplicationRecord
  EVENT_TYPES = %w[wedding quinze_anos formatura bodas adult_birthday children_birthday corporate_event].freeze

  has_many :event_owners, dependent: :destroy
  has_many :event_dates, dependent: :destroy
  has_many :guests, dependent: :destroy
  has_many :godparents, dependent: :destroy
  has_many :event_providers, dependent: :destroy
  has_many :providers, through: :event_providers
  has_many :manager_checklists, dependent: :destroy
  has_many :owner_checklists, dependent: :destroy
  has_one :godparent_list, dependent: :destroy

  accepts_nested_attributes_for :event_owners, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true
  validates :event_type, presence: true, inclusion: { in: EVENT_TYPES }
  validates :main_date, presence: true
  validates :estimated_guests, presence: true, numericality: { greater_than: 0 }
  validates :extra_hours, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :contract_total_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :contract_extra_hour_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :contract_receptionists_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  validate :end_time_after_start_time

  scope :by_type, ->(type) { where(event_type: type) }
  scope :upcoming, -> { where("main_date >= ?", Date.current) }
  scope :past, -> { where("main_date < ?", Date.current) }

  def wedding?
    event_type == "wedding"
  end

  def birthday?
    event_type.include?("birthday")
  end

  def corporate?
    event_type == "corporate_event"
  end

  # Sum of every contracted provider value for this event (nil values count as zero).
  def providers_total_cost
    event_providers.sum(:value)
  end

  # Sum of the professional headcount across all providers of this event.
  def providers_total_professionals
    event_providers.sum(:professionals_count)
  end

  # Total already settled (providers marked "pago").
  def providers_paid_total
    event_providers.where(status: "pago").sum(:value)
  end

  # Outstanding balance still owed (total cost minus what is already paid).
  def providers_balance
    providers_total_cost - providers_paid_total
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time

    if end_time <= start_time
      errors.add(:end_time, "deve ser após o horário de início")
    end
  end
end
