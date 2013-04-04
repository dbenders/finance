class Expense < ActiveRecord::Base
  set_table_name "statement_expenses"
	belongs_to :statement
  attr_accessible :ammount, :date, :installment, :num, :description, :total_installments, :recurring, :categories

  # def categories
  #   self[:categories].split(',')
  # end

  # def categories=(cat)
  #   self[:categories] = cat.join(',')
  # end

end
