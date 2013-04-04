class CategoryRulesController < ApplicationController
  # GET /category_rules
  # GET /category_rules.json
  def index
    @category_rules = CategoryRule.all
    @new_category_rule = CategoryRule.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @category_rules }
    end
  end

  # GET /category_rules/1
  # GET /category_rules/1.json
  def show
    @category_rule = CategoryRule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @category_rule }
    end
  end

  # GET /category_rules/new
  # GET /category_rules/new.json
  def new
    @category_rule = CategoryRule.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @category_rule }
    end
  end

  # GET /category_rules/1/edit
  def edit
    @category_rule = CategoryRule.find(params[:id])
  end

  # POST /category_rules
  # POST /category_rules.json
  def create
    @category_rule = CategoryRule.new(params[:category_rule])

    respond_to do |format|
      if @category_rule.save
        format.html { redirect_to category_rules_path, notice: 'Category rule was successfully created.' }
        format.json { render json: @category_rule, status: :created, location: @category_rule }
      else
        format.html { render action: "index" }
        format.json { render json: @category_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /category_rules/1
  # PUT /category_rules/1.json
  def update
    @category_rule = CategoryRule.find(params[:id])

    respond_to do |format|
      if @category_rule.update_attributes(params[:category_rule])
        format.html { redirect_to @category_rule, notice: 'Category rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @category_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /category_rules/1
  # DELETE /category_rules/1.json
  def destroy
    @category_rule = CategoryRule.find(params[:id])
    @category_rule.destroy

    respond_to do |format|
      format.html { redirect_to category_rules_url }
      format.json { head :no_content }
    end
  end

  def apply    
    rules = CategoryRule.all.collect { |rule| [rule.category, Regexp.new(rule.rule)] }
    Expense.all.each do |exp|
      puts exp.description
      modified = false
      cats = Set.new((exp.categories || "").split(','))
      rules.each do |cat,rule|
        if exp.description =~ rule
          cats << cat
          modified = true
        end
      end
      if modified
        exp.categories = cats.to_a.join(',')
        exp.save
      end      
    end
    respond_to do |format|
      format.html { redirect_to category_rules_url }
      format.json { head :no_content }
    end    
  end
end
