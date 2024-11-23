class CreateMpesaPayments < ActiveRecord::Migration[6.1]
  def change
    create_table :mpesa_payments do |t|
      t.references :cart, null: false, foreign_key: true
      t.string :phone_number
      t.decimal :amount, precision: 10, scale: 2
      t.string :merchant_request_id
      t.string :checkout_request_id
      t.integer :status, default: 0
      t.json :result_payload

      t.timestamps
    end
  end
end