class CreateGuestAndFamilyMemberLists < ActiveRecord::Migration[8.0]
  def up
    create_table :guest_lists do |t|
      t.references :event, null: false, foreign_key: true, index: { unique: true }
      t.string :token, null: false
      t.datetime :expires_at
      t.string :status, null: false, default: "draft"
      t.datetime :submitted_at

      t.timestamps
    end
    add_index :guest_lists, :token, unique: true

    create_table :family_member_lists do |t|
      t.references :event, null: false, foreign_key: true, index: { unique: true }
      t.string :token, null: false
      t.datetime :expires_at
      t.string :status, null: false, default: "draft"
      t.datetime :submitted_at

      t.timestamps
    end
    add_index :family_member_lists, :token, unique: true

    # Backfill: every existing event gets a guest list; weddings also get a
    # family-member list. Idempotent via find_or_create, callbacks intact.
    Event.reset_column_information
    Event.find_each do |event|
      event.find_or_create_guest_list!
      event.find_or_create_family_member_list!
    end
  end

  def down
    drop_table :family_member_lists
    drop_table :guest_lists
  end
end
