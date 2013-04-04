class AddRecurringToStatementExpense < ActiveRecord::Migration
  def change
    add_column :statement_expenses, :recurring, :boolean
  end
end
