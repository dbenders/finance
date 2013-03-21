class StatementExpensesController < ApplicationController
  # GET /statement_expenses
  # GET /statement_expenses.json
  def index
    @statement_expenses = StatementExpense.all(:order => :date)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @statement_expenses }
    end
  end

  # GET /statement_expenses/1
  # GET /statement_expenses/1.json
  def show
    @statement_expense = StatementExpense.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @statement_expense }
    end
  end

  # GET /statement_expenses/new
  # GET /statement_expenses/new.json
  def new
    @statement_expense = StatementExpense.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @statement_expense }
    end
  end

  # GET /statement_expenses/1/edit
  def edit
    @statement_expense = StatementExpense.find(params[:id])
  end

  # POST /statement_expenses
  # POST /statement_expenses.json
  def create
    @statement_expense = StatementExpense.new(params[:statement_expense])

    respond_to do |format|
      if @statement_expense.save
        format.html { redirect_to @statement_expense, notice: 'Statement expense was successfully created.' }
        format.json { render json: @statement_expense, status: :created, location: @statement_expense }
      else
        format.html { render action: "new" }
        format.json { render json: @statement_expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /statement_expenses/1
  # PUT /statement_expenses/1.json
  def update
    @statement_expense = StatementExpense.find(params[:id])

    respond_to do |format|
      if @statement_expense.update_attributes(params[:statement_expense])
        format.html { redirect_to @statement_expense, notice: 'Statement expense was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @statement_expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statement_expenses/1
  # DELETE /statement_expenses/1.json
  def destroy
    @statement_expense = StatementExpense.find(params[:id])
    @statement_expense.destroy

    respond_to do |format|
      format.html { redirect_to statement_expenses_url }
      format.json { head :no_content }
    end
  end
end
