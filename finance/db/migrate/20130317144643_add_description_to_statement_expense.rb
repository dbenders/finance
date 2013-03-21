class AddDescriptionToStatementExpense < ActiveRecord::Migration
  def change
    add_column :statement_expenses, :description, :string
  end
end
