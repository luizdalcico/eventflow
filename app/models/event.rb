class Event < ApplicationRecord
  EVENT_TYPES = %w[wedding quinze_anos formatura bodas adult_birthday children_birthday corporate_event].freeze

  # Whitelisted keys for the home date filter. Order mirrors the UI options.
  DATE_FILTERS = %w[this_week this_month next_month this_year last_year next_year].freeze

  has_many :event_owners, dependent: :destroy
  has_many :event_dates, dependent: :destroy
  has_many :guests, dependent: :destroy
  has_many :godparents, dependent: :destroy
  has_many :procession_steps, dependent: :destroy
  has_many :family_members, dependent: :destroy
  has_many :event_providers, dependent: :destroy
  has_many :providers, through: :event_providers
  has_many :manager_checklists, dependent: :destroy
  has_many :owner_checklists, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :meetings, dependent: :destroy
  has_many :pendencies, dependent: :destroy
  has_one :godparent_list, dependent: :destroy
  has_one :guest_list, dependent: :destroy
  has_one :family_member_list, dependent: :destroy

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

  after_create :ensure_godparent_list
  after_create :ensure_guest_list
  after_create :ensure_family_member_list

  scope :by_type, ->(type) { where(event_type: type) }
  scope :upcoming, -> { where("main_date >= ?", Date.current) }
  scope :past, -> { where("main_date < ?", Date.current) }

  # Case-insensitive match on the event title or any owner's name.
  # Blank query is a no-op so the scope composes cleanly.
  scope :search, ->(query) {
    next all if query.blank?

    pattern = "%#{sanitize_sql_like(query.strip)}%"
    left_outer_joins(:event_owners)
      .where("events.title ILIKE :p OR event_owners.name ILIKE :p", p: pattern)
      .distinct
  }

  # Restrict to events whose main_date falls in the given named period.
  # Unknown or blank periods are a no-op (return everything).
  scope :in_date_range, ->(period) {
    range = date_filter_range(period)
    range ? where(main_date: range) : all
  }

  # Maps a whitelisted DATE_FILTERS key to a concrete date range, or nil.
  def self.date_filter_range(period)
    return nil unless DATE_FILTERS.include?(period.to_s)

    today = Date.current
    case period.to_s
    when "this_week"  then today.beginning_of_week..today.end_of_week
    when "this_month" then today.beginning_of_month..today.end_of_month
    when "next_month"
      next_month = today.next_month
      next_month.beginning_of_month..next_month.end_of_month
    when "this_year"  then today.beginning_of_year..today.end_of_year
    when "last_year"
      last_year = today.last_year
      last_year.beginning_of_year..last_year.end_of_year
    when "next_year"
      next_year = today.next_year
      next_year.beginning_of_year..next_year.end_of_year
    end
  end

  def wedding?
    event_type == "wedding"
  end

  def birthday?
    event_type.include?("birthday")
  end

  def corporate?
    event_type == "corporate_event"
  end

  # Returns the godparent list, creating it on demand for weddings that predate
  # automatic generation. Idempotent: never builds a second list.
  def find_or_create_godparent_list!
    godparent_list || (create_godparent_list! if wedding?)
  end

  # Returns the guest list, creating it on demand for events that predate
  # automatic generation. Available for every event type. Idempotent.
  def find_or_create_guest_list!
    guest_list || create_guest_list!
  end

  # Returns the family-member list, creating it on demand for weddings that
  # predate automatic generation. Weddings only. Idempotent.
  def find_or_create_family_member_list!
    family_member_list || (create_family_member_list! if wedding?)
  end

  # Sum of every contracted provider value for this event (nil values count as zero).
  def providers_total_cost
    event_providers.sum(:value)
  end

  # Sum of the professional headcount across all providers of this event.
  def providers_total_professionals
    event_providers.sum(:professionals_count)
  end

  # Total already settled, summing each provider's paid amount (supports partial payments).
  def providers_paid_total
    event_providers.sum(:paid_value)
  end

  # Outstanding balance still owed (total cost minus what is already paid).
  def providers_balance
    providers_total_cost - providers_paid_total
  end

  # Sum of every payment received from the contratante for this event.
  def payments_total
    payments.sum(:amount)
  end

  # Automatic balance still owed on the contract ("RESTANDO"): the contract
  # total minus everything already paid. A blank contract value counts as zero,
  # and overpayments simply produce a negative balance.
  def payments_balance
    (contract_total_value || 0) - payments_total
  end

  # Dynamic fields merged into the contract PDF, paired with their human label.
  # Order mirrors the event form so the "missing fields" list reads top-down.
  CONTRACT_REQUIRED_FIELDS = [
    [ :start_time, "Horário de início" ],
    [ :end_time, "Horário de término" ],
    [ :extra_hours, "Horas extras" ],
    [ :contract_total_value, "Valor total" ],
    [ :contract_extra_hour_rate, "Valor da hora extra" ],
    [ :contract_payment_due_date, "Data limite de pagamento" ],
    [ :contract_receptionists_count, "Nº de recepcionistas" ]
  ].freeze

  # Labels of the contract fields still blank, so the contract cannot be generated.
  # Includes the contratante (first event owner) name + CPF, which feed the preamble.
  def missing_contract_fields
    missing = CONTRACT_REQUIRED_FIELDS.filter_map { |attr, label| label if self[attr].blank? }
    contratante = event_owners.first
    missing << "Nome do contratante" if contratante&.name.blank?
    missing << "CPF do contratante" if contratante&.cpf.blank?
    missing
  end

  # True when every dynamic contract field is filled in.
  def contract_ready?
    missing_contract_fields.empty?
  end

  private

  # Every wedding gets a godparent list ready to be filled in from the start.
  def ensure_godparent_list
    find_or_create_godparent_list!
  end

  # Every event gets a guest list ready to be filled in from the start.
  def ensure_guest_list
    find_or_create_guest_list!
  end

  # Every wedding gets a family-member list ready to be filled in from the start.
  def ensure_family_member_list
    find_or_create_family_member_list!
  end

  # start_time/end_time are time-of-day only (no date), so an end earlier on the
  # clock than the start is a valid event that runs past midnight into the next day.
  # The only degenerate case left to reject is start == end (zero-length).
  def end_time_after_start_time
    return unless start_time && end_time

    if end_time == start_time
      errors.add(:end_time, "deve ser diferente do horário de início")
    end
  end
end
