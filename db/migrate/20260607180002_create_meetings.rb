class CreateMeetings < ActiveRecord::Migration[8.0]
  def change
    create_table :meetings do |t|
      t.references :event, null: false, foreign_key: true
      t.date :date, null: false
      t.string :participants
      t.text :summary

      t.timestamps
    end

    add_index :meetings, [ :event_id, :date ]
  end
end
