class ExpensesController < ApplicationController
  # GET /expenses
  # GET /expenses.json
  def index
    @expenses = Expense.all(:order => :date)
    @month = (params[:month] || "0").to_i
    if @month > 0
      @expenses = @expenses.select {|exp| not exp.statement.nil? and not exp.statement.closing_date.nil? and exp.statement.closing_date.month == @month}
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @expenses }
    end
  end

  # GET /expenses/1
  # GET /expenses/1.json
  def show
    @expense = Expense.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @expense }
    end
  end

  # GET /expenses/new
  # GET /expenses/new.json
  def new
    @statement = Statement.find(params[:statement_id])
    @expense = Expense.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @expense }
    end
  end

  # GET /expenses/1/edit
  def edit
    @statement = Statement.find(params[:statement_id])    
    @expense = Expense.find(params[:id])
  end

  # POST /expenses
  # POST /expenses.json
  def create
    recurring = params[:expense].delete(:recurring)
    statement = Statement.find(params[:statement_id])
    @expense = Expense.new(params[:expense])
    @expense.statement = statement
    @expense.recurring = recurring

    respond_to do |format|
      if @expense.save
        format.html { redirect_to @expense.statement, notice: 'Statement expense was successfully created.' }
        format.json { render json: @expense, status: :created, location: @expense }
      else
        format.html { render action: "new" }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /expenses/1
  # PUT /expenses/1.json
  def update
    @expense = Expense.find(params[:id])

    respond_to do |format|
      if @expense.update_attributes(params[:expense])
        format.html { redirect_to [@expense.statement.account, @expense.statement], notice: 'Statement expense was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expenses/1
  # DELETE /expenses/1.json
  def destroy
    @expense = Expense.find(params[:id])
    @expense.destroy

    respond_to do |format|
      format.html { redirect_to account_statement_url(params[:account_id],params[:statement_id]) }
      format.json { head :no_content }
    end
  end

  def toggle_recurring
    expense = Expense.find(params[:expense_id])
    expense.recurring = (!expense.recurring)? true : false
    respond_to do |format|
      if expense.save  
        format.html { redirect_to account_statement_url(params[:account_id],params[:statement_id]), notice: 'Statement expense was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: expense.errors, status: :unprocessable_entity }
      end
    end    
  end
end
