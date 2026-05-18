class AddEmailToEventOwners < ActiveRecord::Migration[8.0]
  def change
    add_column :event_owners, :email, :string
  end
end
