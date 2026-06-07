class CreateEventDates < ActiveRecord::Migration[8.0]
  def change
    create_table :event_dates do |t|
      t.references :event, null: false, foreign_key: true
      t.date :date, null: false
      t.string :description, null: false

      t.timestamps
    end

    add_index :event_dates, [ :event_id, :date ]
  end
end
