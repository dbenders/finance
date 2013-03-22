class Account < ActiveRecord::Base
	has_many :statements, :order => 'closing_date ASC'
  attr_accessible :name

  def current_statement
    statements.last

  def last_statement
    statements.all[statements.size-2]
  end

  def current_expenses
    d = statements.find_by_closing_date(nil)
    (d.nil?)? [] : d.statement_expenses
  end  

  def self.forecast
    ans = {}

    all.each do |acct| 
      acct.forecast.each do |date,f| 
        (ans[date.month]||={})[:total] = (ans[date.month][:total] || 0.0) + f[:total]
        ans[date.month][:total_with_installments] = (ans[date.month][:total_with_installments] || 0.0) + f[:total_with_installments]
      end
    end
    puts ans
    ans
  end

  def forecast
    ans = {}
    statements.select { |stmt| not stmt.closing_date.nil? }.each do |stmt|
      ans[stmt.closing_date] = {:total_with_installments => stmt.ammount_with_installments, :total => stmt.ammount }            
    end    
    return {} if ans.empty?

    last_date = ans.keys.max
    last_stmt = statements.find_by_closing_date(last_date)    

    last_stmt.statement_expenses.each do |trans|
      if trans.installment > 0 and trans.total_installments > trans.installment
        d = last_date
        (1..trans.total_installments-trans.installment).each do |i|
          d = d.to_time.advance(:months => 1).to_date
          ans[d] = {:total => 0.0, :total_with_installments => 0.0} if not ans.has_key?(d)
          ans[d][:total] += trans.ammount
          ans[d][:total_with_installments] += trans.ammount
        end
      end
    end

    last_expenses.each do |trans|
      d = last_date.to_time.advance(:months => 1).to_date
      ans[d] = {:total => 0.0, :total_this_month => 0.0, :total_with_installments => 0.0} if not ans.has_key?(d)
      ans[d][:total] += trans.ammount

      if trans.installment == 1        
        ans[d][:total_with_installments] += trans.ammount
        (1..trans.total_installments-trans.installment).each do |i|
          d = d.to_time.advance(:months => 1).to_date
          ans[d] = {:total => 0.0, :total_with_installments => 0.0} if not ans.has_key?(d)
          ans[d][:total] += trans.ammount
          ans[d][:total_with_installments] += trans.ammount
        end
      end
    end
    ans
  end
end
