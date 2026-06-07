class AddContractorFieldsToEventOwners < ActiveRecord::Migration[8.0]
  def change
    add_column :event_owners, :address, :string
    add_column :event_owners, :mother_name, :string
    add_column :event_owners, :father_name, :string
    add_column :event_owners, :birth_date, :date
    add_column :event_owners, :instagram, :string
  end
end
