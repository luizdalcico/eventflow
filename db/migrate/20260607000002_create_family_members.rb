class CreateFamilyMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :family_members do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name, null: false
      t.string :role        # pai_noiva | mae_noiva | pai_noivo | ... | dama | pajem | testemunha | outro
      t.string :notes
      t.integer :position
      t.timestamps
    end
    add_index :family_members, [ :event_id, :position ]
  end
end
