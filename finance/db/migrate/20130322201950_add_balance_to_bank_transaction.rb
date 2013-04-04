class AddBalanceToBankTransaction < ActiveRecord::Migration
  def change
    add_column :bank_transactions, :balance, :float
  end
end
