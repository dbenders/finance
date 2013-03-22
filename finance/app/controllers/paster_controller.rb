class PasterController < ApplicationController

	def index
	end

	def create
		text = params[:text]
		
		data = patagonia_statement(text) || patagonia_last_transactions(text) || statement(text) || last_transactions(text)

		if not data.empty?
			acct = Account.find_or_create_by_name(data[:account_name])			
			stmt = Statement.find_or_create_by_account_id_and_closing_date(acct.id, data[:closing_date][:current])
			stmt.due_date = data[:due_date][:current]
			stmt.save!

			if stmt.due_date.nil?
				stmt.statement_expenses.clear
			end

			for expense_data in data[:transactions] do
				expense = StatementExpense.find_or_create_by_statement_id_and_num(stmt.id, expense_data[:num])
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

	def patagonia_statement(text)
		ans = {}

		m = text.match(/\nTarjeta:(.*)\r?\n/)
		return nil if m.nil?

		ans[:account_name] = m[1].strip
		ans[:closing_date] = {}
		ans[:due_date] = {}
		m = text.scan(/ltimo(\d{2}\/\d{2}\/\d{4})(\d{2}\/\d{2}\/\d{4})/)
		ans[:closing_date][:current] = Date.parse(m[0][0],'%d/%m/%y')
		ans[:due_date][:current] = Date.parse(m[0][1],'%d/%m/%y')
		
		ans[:transactions] = []
		text.scan(/(\d{2}\/\d{2}\/\d{2}) (.{35})  (.{7}) (.{12}) {13}\r?\n/).each do |m|
			m2 = m[1].scan(/C.(\d{2})\/(\d{2})/)
			installment = (m2.empty?)? 0 : m2[0][0].to_i
			total_installments = (m2.empty?)? 0 : m2[0][1].to_i
			ammount = m[3].sub(',','.').strip
			if ammount[-1] == '-' 
				ammount = '-' + ammount[0..-2]
			end
			d = m[0][0..4] + "/20" + m[0][6..9]
			ans[:transactions] << {
				:date => Date.parse(d,'%d/%m/%y'),
				:description => m[1].strip,
				:installment => installment,
				:total_installments => total_installments,
				:num => m[2],
				:ammount => ammount.to_f
			}
		end
		puts ans
		ans
	end		

	def statement(text)
		ans = {}

		m = text.match(/LTIMO RESUMEN\t\r?\n(.*)\r?\n\r?\n/)
		return nil if m.nil?

		ans[:account_name] = m[1]
		ans[:closing_date] = {}
		ans[:due_date] = {}
		text.scan(/\r?\n(.*)\t(\d{2}\/\d{2}\/\d{4})\t(\d{2}\/\d{2}\/\d{4})\t/) do |m|
			if m[0] == "Actual"
				n = :current
			elif m[0].include? "ximo"
				n = :next
			else
				 n = :prev
			end				 
			ans[:closing_date][n] = Date.parse(m[1],'%d/%m/%y')
			ans[:due_date][n = Date.parse(m[2],'%d/%m/%y')
		end
		ans[:transactions] = statement_transactions(text)
		ans
	end

	def last_transactions(text)
		ans = {}
		m = text.match(/LTIMOS CONSUMOS\t\r?\n(.*)\r?\n/)
		return nil if m.nil?
		
		ans[:account_name] = m[1]
		ans[:closing_date] = {:current => nil}
		ans[:due_date] = {:current => nil}
		trans = []
		text.scan(/(\d{2}\/\d{2}\/\d{4})\t(.*)\t(\d+)\t(\d+)\t(\d+(?:,\d{2})?)/) do |m|
			m2 = m[1].scan(/(\d{2})\/(\d{2})/)
			installment = (m2.empty?)? 0 : m2[0][0].to_i
			total_installments = (m2.empty?)? 0 : m2[0][1].to_i
			data = { 
				:date => Date.parse(m[0],'%d/%m/%Y'),
				:description => m[1],
				:installment => installment,
				:total_installments => total_installments,
				:num => m[3],
				:ammount => m[4].sub(',','.').to_f
			}
			trans << data
		end
		ans[:transactions] = trans
		ans
	end

	def patagonia_last_transactions(text)
		ans = {}
		m = text.match(/Tarjetas   \r?\n(.*)\r?\n/)
		return nil if m.nil?
		ans[:account_name] = m[1]
		ans[:closing_date] = {:current => nil}
		ans[:due_date] = {:current => nil}
		trans = []
		text.scan(/(\d{2}\/\d{2}\/\d{4})\t(.*)\t(\d+)\t (\d+)\t \$ +(\d+(?:,\d{2})?)/) do |m|
			m2 = m[1].scan(/(\d{2})\/(\d{2})/)
			installment = (m2.empty?)? 0 : m2[0][0].to_i
			total_installments = (m2.empty?)? 0 : m2[0][1].to_i
			data = { 
				:date => Date.parse(m[0],'%d/%m/%Y'),
				:description => m[1],
				:installment => installment,
				:total_installments => total_installments,
				:num => "#{m[2]}-#{m[3]}",
				:ammount => m[4].sub(',','.').to_f
			}
			trans << data
		end
		ans[:transactions] = trans
		puts ans
		ans
	end

	def statement_transactions(text)
		ans = []

		text.scan(/(\d{2}\/\d{2}\/\d{2}) (.{35})  (.{6}).(.{13})/) do |m|
			m2 = m[1].scan(/C.(\d{2})\/(\d{2})/)
			installment = (m2.empty?)? 0 : m2[0][0].to_i
			total_installments = (m2.empty?)? 0 : m2[0][1].to_i
			ammount = m[3].sub(',','.').strip
			if ammount[-1] == '-' 
				ammount = '-' + ammount[0..-2]
			end
			d = m[0][0..4] + "/20" + m[0][6..9]
			data = {
				:date => Date.parse(d,'%d/%m/%y'),
				:description => m[1].strip,
				:installment => installment,
				:total_installments => total_installments,
				:num => m[2],
				:ammount => ammount.to_f
			}
			ans << data
		end
		ans
	end

end
