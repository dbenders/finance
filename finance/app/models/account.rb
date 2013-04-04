class Account < ActiveRecord::Base
	has_many :statements, :order => 'closing_date ASC'
  attr_accessible :name, :account_type

  def to_s
    name
  end

  def account_type_readable
    case account_type 
    when :credit_card.to_s
      "Tarjeta de Credito"
    when :loan.to_s
      "Credito"
    when :certificate_of_deposit.to_s
      "Plazo fijo"
    when :expenses.to_s
      "Cuenta de gastos"      
    else
      "Cuenta de credito"
    end
  end

  def self.credit_cards
    all.select { |acct| acct.account_type == :credit_card.to_s }
  end

  def self.loans
    all.select { |acct| acct.account_type == :loan.to_s }
  end

  def self.certificates_of_deposit
    all.select { |acct| acct.account_type == :certificate_of_deposit.to_s }
  end

  def self.expense_accounts
    all.select { |acct| acct.account_type == :expenses.to_s }
  end

  def self.account_types
    [ ["Tarjeta de Credito",:credit_card],
      ["Credito",:loan],
      ["Cuenta de gastos",:expenses]
    ]
  end
  
  def self.statements
    ans = {}
    all.each do |acct| 
      acct.statements.each do |stmt|
        month = stmt.closing_date.month
        ans[month] ||= StatementMock.new(stmt.closing_date.to_time.advance(:days => -stmt.closing_date.day+1).to_date)
        ans[month].ammount += stmt.ammount
        ans[month].ammount_with_installments += stmt.ammount_with_installments
        ans[month].ammount_with_recurring += stmt.ammount_with_recurring
      end
    end
    ans.values
  end

  def self.recurring_transactions
    all
      .select { |acct| not acct.current_statement.nil? }
      .collect { |acct| acct.current_statement.expenses.all.select { |trans| trans.recurring } }
      .flatten
  end

  def current_statement
    statements.select { |stmt| not stmt.due_date.nil? }.last
  end

  def last_statement
    statements.select { |stmt| not stmt.due_date.nil? }[-2]
  end

  def current_expenses
    d = statements.find_by_closing_date(nil)
    (d.nil?)? [] : d.expenses
  end  

  def rebuild_future
    #statements.delete_all("due_date is null")
    statements.select { |stmt| stmt.due_date.nil? }.each do |stmt|
      stmt.delete
    end

    # last -> current
    stmt = current_statement
    if not last_statement.nil?
      last_statement.expenses
        .select { |exp| (exp.installment > 0 and exp.total_installments - exp.installment > 0) or (exp.recurring) }
        .each do |exp|

          exp2 = Expense.find_or_create_by_statement_id_and_num(stmt.id, exp.num)
          [:ammount, :date, :description, :total_installments, :recurring].each { |k| exp2[k] = exp[k] }
          if exp.installment > 0
            exp2.installment = exp.installment + 1
          else
            exp2.installment = 0
          end
          exp2.save!
      end

      true
    end

    current_expenses = current_statement.expenses    
    # current -> future    
    i=1
    d = current_statement.closing_date
    modified = true
    while modified
      modified = false
      d = d.to_time.advance(:months => 1).to_date

      stmt = Statement.find_or_create_by_account_id_and_closing_date(id, d)
      stmt.expenses.clear
      current_expenses.select { |exp| exp.installment > 0 and exp.total_installments - exp.installment >= i }.each do |exp|
        exp2 = Expense.new
        [:ammount, :date, :num, :description, :total_installments, :recurring].each { |k| exp2[k] = exp[k] }        
        exp2.statement = stmt
        modified = true
        exp2.installment = exp.installment + i
        exp2.save!       
      end
      i = i+1
    end

    d = current_statement.closing_date
    (1..10).each do |j|
      d = d.to_time.advance(:months => 1).to_date

      stmt = Statement.find_or_create_by_account_id_and_closing_date(id, d)
      current_expenses.select { |exp| exp.recurring }.each do |exp|
        modified = true
        exp2 = Expense.new
        [:ammount, :date, :num, :description, :total_installments, :recurring].each { |k| exp2[k] = exp[k] }        
        exp2.statement = stmt
        exp2.installment = 0
        exp2.save!       
        puts "(#{j}) #{exp2.date} - #{exp2.description}"
      end
    end
    true
  end

end

class StatementMock
  attr_accessor :ammount, :ammount_with_installments, :ammount_with_recurring, :closing_date

  def initialize(closing_date)
    @ammount = 0
    @ammount_with_installments = 0
    @ammount_with_recurring = 0
    @closing_date = closing_date
  end
end

