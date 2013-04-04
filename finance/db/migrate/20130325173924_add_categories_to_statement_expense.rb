class AddCategoriesToStatementExpense < ActiveRecord::Migration
  def change
    add_column :expenses, :categories, :string
  end
end
