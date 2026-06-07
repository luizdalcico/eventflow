module PublicLinkList
  extend ActiveSupport::Concern

  STATUSES = %w[draft submitted].freeze

  # Length of the public token. Short for a tidy URL; the uniqueness check
  # on create guards against the rare base58 collision at this length.
  TOKEN_LENGTH = 6

  included do
    belongs_to :event

    validates :status, inclusion: { in: STATUSES }
    validates :token, presence: true, uniqueness: true

    before_validation :ensure_token, on: :create
  end

  def to_param
    token
  end

  def submitted?
    status == "submitted"
  end

  # The list stays open until the owners explicitly finalize it.
  def editable?
    !submitted?
  end

  def finalize!
    update!(status: "submitted", submitted_at: Time.current)
  end

  private

  def ensure_token
    return if token.present?

    self.token = loop do
      candidate = SecureRandom.base58(TOKEN_LENGTH)
      break candidate unless self.class.exists?(token: candidate)
    end
  end
end
