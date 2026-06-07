class CreatePendencies < ActiveRecord::Migration[8.0]
  def change
    create_table :pendencies do |t|
      t.references :event, null: false, foreign_key: true
      t.references :meeting, foreign_key: true
      t.references :event_provider, foreign_key: true
      t.string :description, null: false
      t.string :assignee
      t.string :status, null: false, default: "pendente"
      t.date :due_date

      t.timestamps
    end

    add_index :pendencies, [ :event_id, :status ]
  end
end
