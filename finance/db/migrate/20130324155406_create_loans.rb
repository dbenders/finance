class CreateLoans < ActiveRecord::Migration
  def change
    create_table :loans do |t|
      t.string :type
      t.string :num
      t.integer :total_installments
      t.float :ammount

      t.timestamps
    end
  end
end
