class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :name
      t.string :cbu

      t.timestamps
    end
  end
end
