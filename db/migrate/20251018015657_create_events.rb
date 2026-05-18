class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :event_type, null: false
      t.date :main_date, null: false
      t.time :start_time
      t.time :end_time
      t.string :place
      t.text :address
      t.integer :estimated_guests
      t.decimal :extra_hours, precision: 8, scale: 2

      t.timestamps
    end

    add_index :events, :event_type
    add_index :events, :main_date
  end
end
