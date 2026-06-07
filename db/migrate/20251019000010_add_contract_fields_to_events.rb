class AddContractFieldsToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :contract_total_value, :decimal, precision: 10, scale: 2
    add_column :events, :contract_extra_hour_rate, :decimal, precision: 10, scale: 2
    add_column :events, :contract_payment_due_date, :date
    add_column :events, :contract_receptionists_count, :integer
  end
end
