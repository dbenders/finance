class AddStatementToStatementExpense < ActiveRecord::Migration
  def change
    add_column :statement_expenses, :statement_id, :integer
  end
end
