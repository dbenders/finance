class Statement < ActiveRecord::Base
  belongs_to :account
  has_many :expenses
  attr_accessible :closing_date, :due_date

  def ammount
    expenses.all.select {|exp| not (exp.description || "").include? "SU PAGO"}.collect { |exp| exp.ammount }.sum
  end

  def ammount_with_recurring
    expenses.all.select {|exp| exp.recurring}.collect { |exp| exp.ammount }.sum
  end

  def ammount_with_installments
    expenses.all.select { |exp| (exp.installment || 0) > 0 }.collect { |exp| exp.ammount }.sum
  end

end
