class RemoveExpiresAtFromPublicLinkLists < ActiveRecord::Migration[8.0]
  # Public lists no longer expire — they stay open until the owners finalize.
  def change
    remove_column :godparent_lists, :expires_at, :datetime
    remove_column :guest_lists, :expires_at, :datetime
    remove_column :family_member_lists, :expires_at, :datetime
  end
end
