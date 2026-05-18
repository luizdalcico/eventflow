class CreateEventProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :event_providers do |t|
      t.references :event, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: true
      t.json :custom_details

      t.timestamps
    end

    add_index :event_providers, [:event_id, :provider_id], unique: true
  end
end
