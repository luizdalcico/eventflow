class AddGodparentFieldsToGuests < ActiveRecord::Migration[8.0]
  def change
    add_column :guests, :godparent_role, :string
    add_column :guests, :side, :string
    add_column :guests, :position, :integer
    add_column :guests, :relationship, :string
    add_column :guests, :couple_sibling, :boolean, default: false, null: false

    add_index :guests, [:event_id, :side, :position]
  end
end
