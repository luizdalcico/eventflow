class CreateProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :providers do |t|
      t.string :provider_type, null: false
      t.string :name, null: false
      t.string :document, null: false
      t.string :contact_name, null: false
      t.string :phone_number, null: false

      t.timestamps
    end

    add_index :providers, :provider_type
    add_index :providers, [ :provider_type, :name ]
  end
end
