class AllowNullGuestName < ActiveRecord::Migration[8.0]
  def change
    # Padrinhos são criados em branco no preenchimento colaborativo e preenchidos
    # depois via auto-save; a obrigatoriedade do nome fica no nível de validação.
    change_column_null :guests, :name, true
  end
end
