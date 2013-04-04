# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130325181207) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "account_type"
  end

  create_table "bank_accounts", :force => true do |t|
    t.string   "name"
    t.string   "cbu"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bank_transactions", :force => true do |t|
    t.date     "date"
    t.string   "description"
    t.float    "ammount"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.float    "balance"
    t.integer  "bank_account_id"
  end

  create_table "category_rules", :force => true do |t|
    t.string   "category"
    t.string   "rule"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "loans", :force => true do |t|
    t.string   "type"
    t.string   "num"
    t.integer  "total_installments"
    t.float    "ammount"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "statement_expenses", :force => true do |t|
    t.date     "date"
    t.string   "num"
    t.integer  "installment"
    t.float    "ammount"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "description"
    t.integer  "statement_id"
    t.integer  "total_installments"
    t.boolean  "recurring"
    t.string   "type"
    t.string   "categories"
  end

  create_table "statements", :force => true do |t|
    t.integer  "account_id"
    t.date     "closing_date"
    t.date     "due_date"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

end
