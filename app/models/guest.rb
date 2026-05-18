class Guest < ApplicationRecord
  belongs_to :event
  belongs_to :godparent_pair, class_name: 'Guest', optional: true
  has_one :paired_godparent, class_name: 'Guest', foreign_key: 'godparent_pair_id'

  validates :name, presence: true
  validates :cpf, format: { with: /\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/, message: 'deve estar no formato XXX.XXX.XXX-XX' }, allow_blank: true

  scope :godparents, -> { where(is_godparent: true) }
  scope :regular_guests, -> { where(is_godparent: false) }

  def godparent?
    is_godparent
  end

  def paired?
    godparent_pair.present?
  end
end
