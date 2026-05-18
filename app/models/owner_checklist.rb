class OwnerChecklist < ApplicationRecord
  belongs_to :event

  validates :task, presence: true

  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }
  scope :overdue, -> { where('due_date < ? AND completed = ?', Date.current, false) }
  scope :due_soon, ->(days = 7) { where('due_date <= ? AND due_date >= ? AND completed = ?', Date.current + days.days, Date.current, false) }

  def overdue?
    due_date.present? && due_date < Date.current && !completed?
  end

  def due_soon?(days = 7)
    due_date.present? && due_date <= Date.current + days.days && due_date >= Date.current && !completed?
  end
end
