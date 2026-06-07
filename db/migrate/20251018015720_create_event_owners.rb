class CreateEventOwners < ActiveRecord::Migration[8.0]
  def change
    create_table :event_owners do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name, null: false
      t.string :cpf
      t.string :phone_number, null: false
      t.string :role

      t.timestamps
    end

    add_index :event_owners, [ :event_id, :role ]
  end
end
