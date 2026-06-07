class RemoveDividedFromGodparentLists < ActiveRecord::Migration[8.0]
  def change
    # O lado (noivo/noiva/nenhum) passou a ser definido por par, na própria
    # página de preenchimento, então a divisão global da lista deixou de existir.
    remove_column :godparent_lists, :divided, :boolean, default: true, null: false
  end
end
