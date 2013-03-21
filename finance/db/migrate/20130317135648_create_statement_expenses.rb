class CreateStatementExpenses < ActiveRecord::Migration
  def change
    create_table :statement_expenses do |t|
      t.date :date
      t.string :num
      t.integer :installment
      t.float :ammount

      t.timestamps
    end
  end
end
