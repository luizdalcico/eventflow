class Pendency < ApplicationRecord
  # Workflow status of an action item raised in (or independent of) a meeting.
  STATUSES = %w[pendente em_andamento concluida].freeze

  belongs_to :event
  belongs_to :meeting, optional: true
  belongs_to :event_provider, optional: true

  validates :description, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :pending, -> { where.not(status: "concluida") }
  scope :ordered, -> { order(:status, :due_date, :id) }
end
