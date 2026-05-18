class CreateOwnerChecklists < ActiveRecord::Migration[8.0]
  def change
    create_table :owner_checklists do |t|
      t.references :event, null: false, foreign_key: true
      t.string :task, null: false
      t.date :due_date
      t.boolean :completed, default: false, null: false
      t.date :reminder_date

      t.timestamps
    end

    add_index :owner_checklists, [:event_id, :due_date]
    add_index :owner_checklists, :completed
  end
end
