class CreateBankTransactions < ActiveRecord::Migration
  def change
    create_table :bank_transactions do |t|
      t.date :date
      t.string :description
      t.float :ammount

      t.timestamps
    end
  end
end
