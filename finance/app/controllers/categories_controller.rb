class CategoriesController < ApplicationController

  def index
    expenses = Expense.all
    @categories = Set.new
    @expenses_by_month = {}
    expenses.each do |exp|
      @categories << exp.categories
      if not exp.statement.nil?
        month = exp.statement.closing_date.month
        @expenses_by_month[month] ||= {}
        @expenses_by_month[month][exp.categories] ||= 0.0
        @expenses_by_month[month][exp.categories] += exp.ammount
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @statements }
    end
  end

end
