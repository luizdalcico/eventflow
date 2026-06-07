class Godparent < ApplicationRecord
  ROLES = %w[madrinha padrinho].freeze
  GODPARENT_SIDES = %w[noivo noiva].freeze
  SIDE_VALUES = (GODPARENT_SIDES + %w[sem_lado]).freeze
  # Relação de cada padrinho/madrinha com o casal.
  PERSON_RELATIONS = %w[irmao amigo avo primo outro].freeze
  # "Os padrinhos são" (relação do par entre si).
  RELATIONSHIPS = %w[casados solteiros irmaos mae_filho pai_filho outro].freeze

  belongs_to :event
  belongs_to :pair, class_name: "Godparent", optional: true

  validates :role, inclusion: { in: ROLES }, allow_blank: true
  validates :side, inclusion: { in: SIDE_VALUES }, allow_blank: true
  validates :relation, inclusion: { in: PERSON_RELATIONS }, allow_blank: true
  validates :relationship, inclusion: { in: RELATIONSHIPS }, allow_blank: true

  scope :ordered, -> { order(:position, :id) }
  scope :anchors, -> { where(role: "madrinha").ordered }
end
