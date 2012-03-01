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

ActiveRecord::Schema.define(:version => 20120301034643) do

  create_table "checkout_asset_tags", :force => true do |t|
    t.string   "uid"
    t.integer  "part_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "checkout_asset_tags", ["part_id"], :name => "index_checkout_asset_tags_on_part_id"

  create_table "checkout_budgets", :force => true do |t|
    t.string   "number"
    t.string   "name"
    t.date     "date_start"
    t.date     "date_end"
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
    t.boolean  "tombstoned"
    t.boolean  "checkoutable"
    t.integer  "location_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "checkout_kits", ["location_id"], :name => "index_checkout_kits_on_location_id"

  create_table "checkout_locations", :force => true do |t|
    t.string   "name"
    t.string   "room"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "checkout_makers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "checkout_models", :force => true do |t|
    t.integer  "maker_id"
    t.string   "name",                                 :null => false
    t.text     "description"
    t.boolean  "training_required", :default => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "checkout_models", ["maker_id"], :name => "index_checkout_models_on_maker_id"

  create_table "checkout_parts", :force => true do |t|
    t.string   "serial_number"
    t.decimal  "cost",          :precision => 8, :scale => 2
    t.boolean  "insured",                                     :default => false
    t.boolean  "missing",                                     :default => false
    t.integer  "budget_id",                                                      :null => false
    t.integer  "kit_id"
    t.integer  "model_id",                                                       :null => false
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
  end

  add_index "checkout_parts", ["budget_id"], :name => "index_checkout_parts_on_budget_id"
  add_index "checkout_parts", ["kit_id"], :name => "index_checkout_parts_on_kit_id"
  add_index "checkout_parts", ["model_id"], :name => "index_checkout_parts_on_model_id"

end
