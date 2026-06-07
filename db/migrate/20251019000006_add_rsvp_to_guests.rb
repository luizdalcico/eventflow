class AddRsvpToGuests < ActiveRecord::Migration[8.0]
  def change
    add_column :guests, :rsvp_status, :string, null: false, default: "pending"
    add_column :guests, :rsvp_sent_at, :datetime
    add_column :guests, :rsvp_responded_at, :datetime
    add_column :guests, :rsvp_message_sid, :string

    add_index :guests, [ :event_id, :rsvp_status ]
  end
end
