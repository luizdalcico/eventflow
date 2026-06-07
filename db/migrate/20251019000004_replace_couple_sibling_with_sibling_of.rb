class ReplaceCoupleSiblingWithSiblingOf < ActiveRecord::Migration[8.0]
  def change
    # "Irmão dos noivos" deixa de ser booleano e passa a indicar de quem é
    # irmão(ã): "noivo", "noiva" ou nil (não é irmão).
    remove_column :guests, :couple_sibling, :boolean, default: false, null: false
    add_column :guests, :sibling_of, :string
  end
end
