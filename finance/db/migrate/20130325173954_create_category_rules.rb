class CreateCategoryRules < ActiveRecord::Migration
  def change
    create_table :category_rules do |t|
      t.string :category
      t.string :rule

      t.timestamps
    end
  end
end
