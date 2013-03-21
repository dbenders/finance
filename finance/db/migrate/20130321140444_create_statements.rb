class CreateStatements < ActiveRecord::Migration
  def change
    create_table :statements do |t|
      t.integer :account_id
      t.date :closing_date
      t.date :due_date

      t.timestamps
    end
  end
end
