class FamilyMember < ApplicationRecord
  # Familiares com papel na cerimônia (além dos padrinhos).
  ROLES = %w[
    pai_noiva mae_noiva pai_noivo mae_noivo
    avo_noiva avo_noivo
    dama pajem testemunha outro
  ].freeze

  belongs_to :event

  validates :name, presence: true
  validates :role, inclusion: { in: ROLES }, allow_blank: true

  scope :ordered, -> { order(:position, :id) }
end
