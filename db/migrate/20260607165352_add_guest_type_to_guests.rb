class AddGuestTypeToGuests < ActiveRecord::Migration[8.0]
  def up
    # Default backfills existing rows in the same statement, so NOT NULL is safe.
    add_column :guests, :guest_type, :string, default: "adult", null: false
    add_index :guests, [ :event_id, :guest_type ], name: "index_guests_on_event_id_and_guest_type"
  end

  def down
    remove_index :guests, name: "index_guests_on_event_id_and_guest_type"
    remove_column :guests, :guest_type
  end
end
