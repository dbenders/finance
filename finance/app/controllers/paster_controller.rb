class PasterController < ApplicationController

	def index
	end

	def create
		text = params[:text]
		text.gsub!(/\r/,'')
		create_statement(text) || create_current(text) || create_account(text) || create_loan(text) || create_cd(text)
		

    respond_to do |format|
    	format.html { redirect_to "/", notice: 'Statement was successfully imported.' }
    	format.json { render json: stmt, status: :created, location: stmt }
		end
	end

private

	def create_account(text)
		data = santander_account(text)
		if not data.nil? and not data.empty?
			acct = BankAccount.find_or_create_by_name(data[:account_name])
			for t in data[:transactions]
				trans = BankTransaction.find_or_create_by_date_and_description_and_balance(t[:date],t[:description],t[:balance])
				trans.ammount = t[:ammount]
				trans.bank_account = acct
				trans.save!
			end
		end
		puts data
	end


	def create_statement(text)	
		data = patagonia_statement(text) || santander_statement(text)

		if not data.nil? and not data.empty?
			acct = Account.find_or_create_by_name_and_account_type(data[:account_name],:credit_card)			
			stmt = Statement.find_or_create_by_account_id_and_closing_date(acct.id, data[:closing_date][:current])
			stmt.due_date = data[:due_date][:current]
			stmt.save!

			for expense_data in data[:transactions] do
				expense = Expense.find_or_create_by_statement_id_and_num(stmt.id, expense_data[:num])
				expense.update_attributes(expense_data)
				expense.save!
			end

			# closing and due date for current statement
			stmt = Statement.find_or_create_by_account_id_and_closing_date(acct.id, data[:closing_date][:next])
			stmt.due_date = data[:due_date][:next]
			stmt.save!

			# rebuild future
			acct.rebuild_future
		end
		data
	end

	def create_current(text)
		data = patagonia_last_transactions(text) || santander_last_transactions(text)
		if not data.nil? and not data.empty?
			acct = Account.find_or_create_by_name_and_account_type(data[:account_name],:credit_card)			
			stmt = acct.current_statement

			for expense_data in data[:transactions] do
				expense = Expense.find_or_create_by_statement_id_and_num(stmt.id, expense_data[:num])
				expense.update_attributes(expense_data)
				expense.save!
			end
		end
		data
	end

	def create_loan(text)
		data = santander_loan(text)
		if not data.nil? and not data.empty?
			data.each do |d|
				acct = Account.find_or_create_by_name_and_account_type(d[:num],:loan)			
				stmt = acct.statements.find_or_create_by_due_date(d[:due_date])
				stmt.closing_date = d[:due_date]

				exp = stmt.expenses.find_or_create_by_num(d[:num])
				exp.ammount = d[:ammount]
				exp.installment = d[:installment]
				exp.ammount = d[:ammount]
				exp.date = d[:due_date]
				exp.description = d[:type]
				
				exp.save
				stmt.save
			end
		end
	end

	def create_cd(text)
		data = santander_cd(text)
		if not data.nil? and not data.empty?
			acct = Account.find_or_create_by_name_and_account_type(data[:account_name],:certificate_of_deposit)							
			data[:transactions].each do |t|				
				d = t[:date].month
				stmt = acct.statements.select { |stmt| stmt.due_date.month == d }
				if stmt.empty?
					d = Date.new(t[:date].year, t[:date].month, 1)
					d = d.advance(:months => 1).advance(:days => -1)
					stmt = acct.statements.create(:closing_date => d, :due_date => d)
					stmt.save
				else
					stmt = stmt[0]
				end
				trans = stmt.expenses.find_or_create_by_date_and_ammount(t[:date],-t[:ammount])
				trans.description = t[:description]
				trans.save
			end
		end
	end

	def santander_cd(text)
		ans = {}
		ans[:account_name] = "Santander Rio"
		ans[:transactions] = []
		m = text.scan(/\n(.*)\t (\d{2}\/\d{2}\/\d{4})\t (.*)\%\t\n\$\t(.*)\n\$\t(.*)\n\$\t(.*)\n/) do |m|
			trans = {}
			trans[:description] = "#{m[0].strip} #{m[3]} al #{m[2]}%"
			trans[:date] = Date.parse(m[1],'%d/%m/%y')
			trans[:ammount] = m[5].sub('.','').sub(',','.').to_f
			ans[:transactions] << trans
		end
		ans
	end


	def patagonia_statement(text)
		ans = {}

		m = text.match(/\nTarjeta:(.*)\n/)
		return nil if m.nil?

		ans[:account_name] = m[1].strip
		ans[:closing_date] = {}
		ans[:due_date] = {}

		m = text.scan(/ltimo(\d{2}\/\d{2}\/\d{4})(\d{2}\/\d{2}\/\d{4})/)
		ans[:closing_date][:current] = Date.parse(m[0][0],'%d/%m/%y')
		ans[:due_date][:current] = Date.parse(m[0][1],'%d/%m/%y')

		m = text.scan(/ximo(\d{2}\/\d{2}\/\d{4})(\d{2}\/\d{2}\/\d{4})/)
		ans[:closing_date][:next] = Date.parse(m[0][0],'%d/%m/%y')
		ans[:due_date][:next] = Date.parse(m[0][1],'%d/%m/%y')
		
		ans[:transactions] = []
		text.scan(/(\d{2}\/\d{2}\/\d{2}) (.{35})  (.{7}) (.{12}) {13}\n/).each do |m|

			if not m[1].include?("SU PAGO")

				m2 = m[1].scan(/(C.(\d{2})\/(\d{2}))/)
				if m2.empty?
					installment = 0
					total_installments = 0
				else
					m[1] = m[1].sub(m2[0][0],'')				
					installment = m2[0][1].to_i
					total_installments = m2[0][2].to_i
				end
				ammount = m[3].sub(',','.').strip
				if ammount[-1] == '-' 
					ammount = '-' + ammount[0..-2]
				end
				num = m[2]
				m[2] = m[2][0..-2] if m[2][-1] == '*'
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
		end		
		ans
	end		

	def santander_account(text)
		ans = {}
		m = text.match(/\nCuenta Unica (.*)\t/)
		return nil if m.nil?

		ans[:account_name] = m[1]
		ans[:transactions] = []
		text.scan(/\n\n(\d{2}\/\d{2}\/\d{2})\n(.*)\n(.*)\n(.*)\n \n(.*)\n/) do |m|
			data = {}
			data[:date] = Date.parse(m[0][0..4] + "/20" + m[0][6..9], '%d/%m/%y')
			data[:description] = "#{m[1].strip}. #{m[2].strip}"
			m[3] = "-" + m[3][1..m[3].size-2] if m[3][0] == '('
			data[:ammount] = m[3].sub('.','').sub(',','.').to_f
			m[4] = "-" + m[4][1..m[4].size-2] if m[4][0] == '('
			data[:balance] = m[4].sub('.','').sub(',','.').to_f			
			ans[:transactions] << data
		end
		ans
	end

	def santander_statement(text)
		ans = {}

		m = text.match(/LTIMO RESUMEN\t\n(.*)\n\n/)
		return nil if m.nil?

		ans[:account_name] = m[1]
		ans[:closing_date] = {}
		ans[:due_date] = {}
		text.scan(/\n(.*)\t(\d{2}\/\d{2}\/\d{4})\t(\d{2}\/\d{2}\/\d{4})\t/) do |m|
			if m[0] == "Actual"
				n = :current
			elsif m[0].include? "ximo"
				n = :next
			else
				 n = :prev
			end				 
			ans[:closing_date][n] = Date.parse(m[1],'%d/%m/%y')
			ans[:due_date][n] = Date.parse(m[2],'%d/%m/%y')
		end
		ans[:transactions] = []

		text.scan(/(\d{2}\/\d{2}\/\d{2}) (.{35})  (.{6}).(.{13})/) do |m|
			
			if not m[1].include?("SU PAGO")

				m2 = m[1].scan(/(C.(\d{2})\/(\d{2}))/)
				if m2.empty?
					installment = 0
					total_installments = 0
				else
					m[1] = m[1].sub(m2[0][0],'')				
					installment = m2[0][1].to_i
					total_installments = m2[0][2].to_i
				end
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
				if data[:num].strip.length == 0
					data[:num] = data.hash.abs.to_s
				end
				ans[:transactions] << data
			end
		end		
		ans
	end

	def santander_last_transactions(text)
		ans = {}
		m = text.match(/LTIMOS CONSUMOS\t\n(.*)\n/)
		return nil if m.nil?
		
		ans[:account_name] = m[1]
		ans[:closing_date] = {:current => nil}
		ans[:due_date] = {:current => nil}
		trans = []
		text.scan(/(\d{2}\/\d{2}\/\d{4})\t(.*)\t(\d+)\t\d(\d+)\t(\d+(?:,\d{2})?)/) do |m|
			m2 = m[1].scan(/((\d{2})\/(\d{2}))/)
			if m2.empty?
				installment = 0
				total_installments = 0
			else
				m[1] = m[1].sub(m2[0][0],'')				
				installment = m2[0][1].to_i
				total_installments = m2[0][2].to_i
			end
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


	def santander_loan(text)
		ans = []
		m = text.match(/\nTipo\tValor\n/)		
		return nil if m.nil?
		text.scan(/(.*)\t(.*)\t(.*)\t(.*)\t(\d+)\t(\d{2}\/\d{2}\/\d{4})\t\n\$\t(.*)\n/) do |m|
			trans = {}
			trans[:type] = m[0].strip
			trans[:num] = m[1].strip
			trans[:installment] = m[4].to_i
			trans[:due_date] = Date.parse(m[5],'%d/%m/%Y')
			trans[:ammount] = m[6].sub('.','').sub(',','.')
			ans << trans
		end
		ans 
	end


	def patagonia_last_transactions(text)
		ans = {}
		m = text.match(/Tarjetas   \n(.*)\n/)
		return nil if m.nil?
		ans[:account_name] = m[1].strip
		ans[:closing_date] = {:current => nil}
		ans[:due_date] = {:current => nil}
		trans = []
		text.scan(/(\d{2}\/\d{2}\/\d{4})\t(.*)\t\d(\d+)\t (\d+)\t \$ +(\d+(?:,\d{2})?)/) do |m|
			m2 = m[1].scan(/((\d{2})\/(\d{2}))/)
			if m2.empty?
				installment = 0
				total_installments = 0
			else
				m[1] = m[1].sub(m2[0][0],'')				
				installment = m2[0][1].to_i
				total_installments = m2[0][2].to_i
			end
			data = { 
				:date => Date.parse(m[0],'%d/%m/%Y'),
				:description => m[1],
				:installment => installment,
				:total_installments => total_installments,
				:num => m[2],
				:ammount => m[4].sub(',','.').to_f
			}
			trans << data
		end
		ans[:transactions] = trans
		puts ans
		ans
	end

end
