class CreateGodparentLists < ActiveRecord::Migration[8.0]
  def change
    create_table :godparent_lists do |t|
      t.references :event, null: false, foreign_key: true, index: { unique: true }
      t.string :token, null: false
      t.datetime :expires_at
      t.string :status, null: false, default: "draft"
      t.datetime :submitted_at
      t.boolean :divided, null: false, default: true

      t.timestamps
    end

    add_index :godparent_lists, :token, unique: true
  end
end
