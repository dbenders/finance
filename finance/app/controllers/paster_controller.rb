class PasterController < ApplicationController

	def index
	end

	def create
		text = params[:text]
		
		data = statement(text)

		#expenses = last_transactions(text)
		#if expenses.empty?
		#	expenses = statement_transactions(text)
		#end
		puts data
		if not data.empty?
			acct = Account.find_or_create_by_name(data[:account_name])
			stmt = Statement.find_or_create_by_account_id_and_closing_date(acct.id, data[:closing_date]["Actual"])
			stmt.due_date = data[:due_date]["Actual"]
			stmt.save!

			for expense_data in data[:transactions] do
				expense = StatementExpense.find_or_create_by_statement_and_num(stmt, expense_data[:num])
				expense.update_attributes(expense_data)
				expense.save!
			end

		end
    	respond_to do |format|
      		format.html { redirect_to stmt, notice: 'Statement was successfully imported.' }
      		format.json { render json: stmt, status: :created, location: stmt }
		end
	end

private

	def last_transactions(text)
		ans = []
		text.scan(/(\d{2}\/\d{2}\/\d{4})\t(.*)\t(\d+)\t(\d+)\t(\d+(?:,\d{2})?)/) do |m|
			m2 = m[1].scan(/(\d{2})\/\d{2}/)
			installment = (m2.empty?)? 1 : m2[0][0].to_i
			data = { 
				:date => Date.parse(m[0],'%d/%m/%Y'),
				:description => m[1],
				:installment => installment,
				:num => m[3],
				:ammount => m[4].sub(',','.').to_f
			}
			ans << data
		end
		ans
	end

	def statement(text)
		ans = {}
		
		m = text.match(/LTIMO RESUMEN\t\r?\n(.*)\r?\n\r?\n/)
		if not m.nil? 
			ans[:account_name] = m[1]
			ans[:closing_date] = {}
			ans[:due_date] = {}
			text.scan(/\r?\n(.*)\t(\d{2}\/\d{2}\/\d{4})\t(\d{2}\/\d{2}\/\d{4})\t/) do |m|
				ans[:closing_date][m[0]] = Date.parse(m[1],'%d/%m/%y')
				ans[:due_date][m[0]] = Date.parse(m[2],'%d/%m/%y')
			end
			ans[:transactions] = statement_transactions(text)
		end
		puts ans
		ans
	end

	def statement_transactions(text)
		ans = []

		text.scan(/(\d{2}\/\d{2}\/\d{2}) (.{35})  (.{6}).(.{13})/) do |m|
			m2 = m[1].scan(/C.(\d{2})\/\d{2}/)
			installment = (m2.empty?)? 0 : m2[0][0].to_i
			ammount = m[3].sub(',','.').strip
			if ammount[-1] == '-' 
				ammount = '-' + ammount[0..-2]
			end
			d = m[0][0..4] + "/20" + m[0][6..9]
			puts d
			data = {
				:date => Date.parse(d,'%d/%m/%y'),
				:description => m[1].strip,
				:installment => installment,
				:num => m[2],
				:ammount => ammount.to_f
			}
			puts data
			ans << data
		end
		ans
	end

end
