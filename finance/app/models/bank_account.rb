class BankAccount < ActiveRecord::Base
  attr_accessible :cbu, :name
  has_many :bank_transactions, :order => 'date ASC'

  def balance
    bank_transactions[-1].balance    
  end
  
  def to_s
    name
  end
end
