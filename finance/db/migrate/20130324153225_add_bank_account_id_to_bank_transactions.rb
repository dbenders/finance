class AddBankAccountIdToBankTransactions < ActiveRecord::Migration
  def change
    add_column :bank_transactions, :bank_account_id, :integer
  end
end
