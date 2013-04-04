class BankTransactionsController < ApplicationController
  # GET /bank_transactions
  # GET /bank_transactions.json
  def index
    @bank_transactions = BankTransaction.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bank_transactions }
    end
  end

  # GET /bank_transactions/1
  # GET /bank_transactions/1.json
  def show
    @bank_transaction = BankTransaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bank_transaction }
    end
  end

  # GET /bank_transactions/new
  # GET /bank_transactions/new.json
  def new
    @bank_transaction = BankTransaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bank_transaction }
    end
  end

  # GET /bank_transactions/1/edit
  def edit
    @bank_transaction = BankTransaction.find(params[:id])
  end

  # POST /bank_transactions
  # POST /bank_transactions.json
  def create
    @bank_transaction = BankTransaction.new(params[:bank_transaction])

    respond_to do |format|
      if @bank_transaction.save
        format.html { redirect_to @bank_transaction, notice: 'Bank transaction was successfully created.' }
        format.json { render json: @bank_transaction, status: :created, location: @bank_transaction }
      else
        format.html { render action: "new" }
        format.json { render json: @bank_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bank_transactions/1
  # PUT /bank_transactions/1.json
  def update
    @bank_transaction = BankTransaction.find(params[:id])

    respond_to do |format|
      if @bank_transaction.update_attributes(params[:bank_transaction])
        format.html { redirect_to @bank_transaction, notice: 'Bank transaction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bank_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_transactions/1
  # DELETE /bank_transactions/1.json
  def destroy
    @bank_transaction = BankTransaction.find(params[:id])
    @bank_transaction.destroy

    respond_to do |format|
      format.html { redirect_to bank_transactions_url }
      format.json { head :no_content }
    end
  end
end
