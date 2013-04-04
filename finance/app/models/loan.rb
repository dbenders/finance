class Loan < ActiveRecord::Base
  attr_accessible :ammount, :num, :total_installments, :type
end
