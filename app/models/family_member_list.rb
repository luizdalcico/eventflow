class FamilyMemberList < ApplicationRecord
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
end
