class GodparentList < ApplicationRecord
  STATUSES = %w[draft submitted].freeze

  belongs_to :event

  has_secure_token :token

  validates :status, inclusion: { in: STATUSES }

  def to_param
    token
  end

  def expired?
    expires_at.present? && expires_at.past?
  end

  def submitted?
    status == "submitted"
  end

  def editable?
    !expired? && !submitted?
  end

  def finalize!
    update!(status: "submitted", submitted_at: Time.current)
  end

  def godparents
    event.godparents.ordered
  end

  # Âncoras (madrinhas) — uma por par, na ordem.
  def anchors
    event.godparents.anchors
  end

  def pairs_count
    event.godparents.where.not(pair_id: nil).count / 2
  end

  # Âncoras (madrinhas) cujos pares ainda têm algum campo em branco.
  def incomplete_anchors
    anchors.reject { |m| pair_complete?(m) }
  end

  # Um par é completo quando madrinha e padrinho têm nome, telefone e relação,
  # e o par tem lado e "os padrinhos são".
  def pair_complete?(madrinha)
    padrinho = madrinha.pair
    return false if padrinho.nil?
    return false if madrinha.side.blank? || madrinha.relationship.blank?

    [madrinha, padrinho].all? do |g|
      g.name.present? && g.phone_number.present? && g.relation.present?
    end
  end

  # Cria um par em branco (madrinha + padrinho ligados) e devolve a âncora.
  def add_pair!
    position = (event.godparents.maximum(:position) || 0) + 1
    transaction do
      madrinha = event.godparents.create!(role: "madrinha", position: position)
      padrinho = event.godparents.create!(role: "padrinho", position: position)
      madrinha.update!(pair_id: padrinho.id)
      padrinho.update!(pair_id: madrinha.id)
      madrinha
    end
  end
end
