class EventDate < ApplicationRecord
  belongs_to :event

  validates :description, presence: true

  scope :upcoming, -> { where("date >= ?", Date.current) }
  scope :past, -> { where("date < ?", Date.current) }
end
