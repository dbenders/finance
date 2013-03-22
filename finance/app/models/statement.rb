class Statement < ActiveRecord::Base
  belongs_to :account
  has_many :statement_expenses
  attr_accessible :closing_date, :due_date

  def ammount
    statement_expenses.all.select {|exp| exp.ammount > 0}.collect { |exp| exp.ammount }.sum
  end

  def ammount_with_installments
    statement_expenses.all.select { |exp| exp.installment > 0 and exp.ammount > 0 }.collect { |exp| exp.ammount }.sum
  end

end
