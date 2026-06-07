class AddPartySizeAndNotesToGuests < ActiveRecord::Migration[8.0]
  def change
    # Cada convidado pode representar mais de uma pessoa (casal/família).
    add_column :guests, :party_size, :integer, null: false, default: 1
    add_column :guests, :notes, :string
  end
end
