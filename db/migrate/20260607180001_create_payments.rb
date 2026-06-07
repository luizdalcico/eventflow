class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :event, null: false, foreign_key: true
      t.string :payer_name, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :reference
      t.string :payment_method, null: false
      t.date :paid_on, null: false

      t.timestamps
    end
  end
end
