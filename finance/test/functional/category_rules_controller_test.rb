require 'test_helper'

class CategoryRulesControllerTest < ActionController::TestCase
  setup do
    @category_rule = category_rules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:category_rules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create category_rule" do
    assert_difference('CategoryRule.count') do
      post :create, category_rule: { category: @category_rule.category, rule: @category_rule.rule }
    end

    assert_redirected_to category_rule_path(assigns(:category_rule))
  end

  test "should show category_rule" do
    get :show, id: @category_rule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @category_rule
    assert_response :success
  end

  test "should update category_rule" do
    put :update, id: @category_rule, category_rule: { category: @category_rule.category, rule: @category_rule.rule }
    assert_redirected_to category_rule_path(assigns(:category_rule))
  end

  test "should destroy category_rule" do
    assert_difference('CategoryRule.count', -1) do
      delete :destroy, id: @category_rule
    end

    assert_redirected_to category_rules_path
  end
end
