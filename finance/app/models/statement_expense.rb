class StatementExpense < ActiveRecord::Base
	belongs_to :statement
  attr_accessible :ammount, :date, :installment, :num, :description
end
