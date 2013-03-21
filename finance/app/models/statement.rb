class Statement < ActiveRecord::Base
  belongs_to :account
  has_many :statement_expenses
  attr_accessible :closing_date, :due_date
end
