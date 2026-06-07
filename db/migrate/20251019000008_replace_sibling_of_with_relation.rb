class ReplaceSiblingOfWithRelation < ActiveRecord::Migration[8.0]
  def change
    # "Irmã de/Irmão de" (noivo/noiva) vira a relação de cada pessoa com o casal
    # (irmão, amigo, avô, primo, outro).
    remove_column :guests, :sibling_of, :string
    add_column :guests, :relation, :string
  end
end
