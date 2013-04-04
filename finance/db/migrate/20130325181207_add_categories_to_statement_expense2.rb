class AddCategoriesToStatementExpense2 < ActiveRecord::Migration
  def change
    add_column :expenses, :categories, :string
  end
end
