require 'test_helper'

class StatementExpensesControllerTest < ActionController::TestCase
  setup do
    @statement_expense = statement_expenses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:statement_expenses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create statement_expense" do
    assert_difference('StatementExpense.count') do
      post :create, statement_expense: { ammount: @statement_expense.ammount, date: @statement_expense.date, installment: @statement_expense.installment, num: @statement_expense.num }
    end

    assert_redirected_to statement_expense_path(assigns(:statement_expense))
  end

  test "should show statement_expense" do
    get :show, id: @statement_expense
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @statement_expense
    assert_response :success
  end

  test "should update statement_expense" do
    put :update, id: @statement_expense, statement_expense: { ammount: @statement_expense.ammount, date: @statement_expense.date, installment: @statement_expense.installment, num: @statement_expense.num }
    assert_redirected_to statement_expense_path(assigns(:statement_expense))
  end

  test "should destroy statement_expense" do
    assert_difference('StatementExpense.count', -1) do
      delete :destroy, id: @statement_expense
    end

    assert_redirected_to statement_expenses_path
  end
end
