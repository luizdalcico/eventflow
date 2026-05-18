class EventProvider < ApplicationRecord
  belongs_to :event
  belongs_to :provider

  validates :event_id, uniqueness: { scope: :provider_id }

  def custom_detail(key)
    custom_details&.dig(key.to_s)
  end

  def set_custom_detail(key, value)
    self.custom_details ||= {}
    self.custom_details[key.to_s] = value
  end
end
