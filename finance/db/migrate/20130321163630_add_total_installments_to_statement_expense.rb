class AddTotalInstallmentsToStatementExpense < ActiveRecord::Migration
  def change
    add_column :statement_expenses, :total_installments, :integer
  end
end
