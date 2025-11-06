class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.integer :client_id, null: false
      t.integer :amount, null: false, default: 0
      t.integer :state, default: 1, null: false
      t.datetime :due_date, null: false

      t.timestamps
    end
  end
end
