class BankTransaction < ActiveRecord::Base
  attr_accessible :ammount, :date, :description
  belongs_to :bank_account
end
