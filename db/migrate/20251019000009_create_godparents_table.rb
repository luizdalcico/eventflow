class CreateGodparentsTable < ActiveRecord::Migration[8.0]
  # Stubs locais para a migração de dados (independentes dos models da app).
  class LegacyGuest < ActiveRecord::Base
    self.table_name = "guests"
  end

  class Godparent < ActiveRecord::Base
  end

  def up
    create_table :godparents do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name
      t.string :phone_number
      t.string :role        # madrinha | padrinho
      t.string :side        # noivo | noiva | sem_lado
      t.string :relation    # relação da pessoa com o casal
      t.string :relationship # "os padrinhos são" (relação do par)
      t.bigint :pair_id     # auto-referência (par madrinha↔padrinho)
      t.integer :position
      t.timestamps
    end
    add_index :godparents, :pair_id
    add_index :godparents, [:event_id, :position]
    add_foreign_key :godparents, :godparents, column: :pair_id

    Godparent.reset_column_information

    # 1) Copia padrinhos de guests -> godparents (mapeando ids antigos -> novos).
    id_map = {}
    LegacyGuest.where(is_godparent: true).order(:id).each do |g|
      gp = Godparent.create!(
        event_id: g.event_id, name: g.name, phone_number: g.phone_number,
        role: g.godparent_role, side: g.side, relation: g.relation,
        relationship: g.relationship, position: g.position,
        created_at: g.created_at, updated_at: g.updated_at
      )
      id_map[g.id] = gp.id
    end

    # 2) Refaz o vínculo do par com os novos ids.
    LegacyGuest.where(is_godparent: true).where.not(godparent_pair_id: nil).each do |g|
      Godparent.where(id: id_map[g.id]).update_all(pair_id: id_map[g.godparent_pair_id])
    end

    # 3) Remove a auto-referência de guests e apaga os padrinhos antigos.
    remove_column :guests, :godparent_pair_id
    LegacyGuest.where(is_godparent: true).delete_all

    # 4) Remove as colunas de padrinho da tabela guests.
    remove_column :guests, :is_godparent
    remove_column :guests, :godparent_role
    remove_column :guests, :side
    remove_column :guests, :relation
    remove_column :guests, :relationship
    remove_column :guests, :position
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
