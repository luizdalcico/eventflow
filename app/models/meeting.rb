class Meeting < ApplicationRecord
  belongs_to :event
  has_many :pendencies, dependent: :nullify

  validates :date, presence: true

  scope :ordered, -> { order(date: :desc, id: :desc) }
end
