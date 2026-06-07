class CreateGuests < ActiveRecord::Migration[8.0]
  def change
    create_table :guests do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name, null: false
      t.string :cpf
      t.string :phone_number
      t.boolean :is_godparent, default: false
      t.references :godparent_pair, null: true, foreign_key: { to_table: :guests }

      t.timestamps
    end

    add_index :guests, [ :event_id, :name ]
    add_index :guests, :is_godparent
  end
end
