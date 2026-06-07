class DropOwnerChecklists < ActiveRecord::Migration[8.0]
  def change
    drop_table :owner_checklists do |t|
      t.references :event, null: false, foreign_key: true
      t.string :task, null: false
      t.date :due_date
      t.boolean :completed, default: false, null: false
      t.date :reminder_date

      t.timestamps

      t.index [ :event_id, :due_date ]
      t.index :completed
    end
  end
end
