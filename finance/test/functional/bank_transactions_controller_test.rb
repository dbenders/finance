require 'test_helper'

class BankTransactionsControllerTest < ActionController::TestCase
  setup do
    @bank_transaction = bank_transactions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bank_transactions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bank_transaction" do
    assert_difference('BankTransaction.count') do
      post :create, bank_transaction: { ammount: @bank_transaction.ammount, date: @bank_transaction.date, description: @bank_transaction.description }
    end

    assert_redirected_to bank_transaction_path(assigns(:bank_transaction))
  end

  test "should show bank_transaction" do
    get :show, id: @bank_transaction
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bank_transaction
    assert_response :success
  end

  test "should update bank_transaction" do
    put :update, id: @bank_transaction, bank_transaction: { ammount: @bank_transaction.ammount, date: @bank_transaction.date, description: @bank_transaction.description }
    assert_redirected_to bank_transaction_path(assigns(:bank_transaction))
  end

  test "should destroy bank_transaction" do
    assert_difference('BankTransaction.count', -1) do
      delete :destroy, id: @bank_transaction
    end

    assert_redirected_to bank_transactions_path
  end
end
