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

ActiveRecord::Schema.define(:version => 20120228232029) do

  create_table "checkout_budgets", :force => true do |t|
    t.string   "number"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "checkout_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "checkout_categories", ["name"], :name => "index_checkout_categories_on_name"

  create_table "checkout_categories_checkout_models", :id => false, :force => true do |t|
    t.integer "checkout_categories_id"
    t.integer "checkout_models_id"
  end

  add_index "checkout_categories_checkout_models", ["checkout_categories_id", "checkout_models_id"], :name => "categories_models_index"

  create_table "checkout_kits", :force => true do |t|
    t.integer  "location_id",                     :null => false
    t.boolean  "tombstoned",   :default => false
    t.boolean  "checkoutable", :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "checkout_makers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "checkout_models", :force => true do |t|
    t.integer  "maker_id",                             :null => false
    t.string   "name",                                 :null => false
    t.text     "description"
    t.boolean  "training_required", :default => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "checkout_parts", :force => true do |t|
    t.integer  "kit_id"
    t.integer  "model_id",                                                       :null => false
    t.string   "serial_number"
    t.decimal  "cost",          :precision => 8, :scale => 2
    t.boolean  "insured",                                     :default => false
    t.boolean  "missing",                                     :default => false
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
  end

end
