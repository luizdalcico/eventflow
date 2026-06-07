class CreateProcessionSteps < ActiveRecord::Migration[8.0]
  def change
    create_table :procession_steps do |t|
      t.references :event, null: false, foreign_key: true
      t.string :description, null: false
      t.string :kind        # entrada | leitura | salmo | aliancas | saida | outro
      t.integer :position
      t.timestamps
    end
    add_index :procession_steps, [ :event_id, :position ]
  end
end
