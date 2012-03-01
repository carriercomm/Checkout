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

ActiveRecord::Schema.define(:version => 20120301072123) do

  create_table "asset_tags", :force => true do |t|
    t.string   "uid"
    t.integer  "part_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "asset_tags", ["part_id"], :name => "index_asset_tags_on_part_id"

  create_table "brands", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "budgets", :force => true do |t|
    t.string   "number"
    t.string   "name"
    t.date     "date_start"
    t.date     "date_end"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "categories", ["name"], :name => "index_categories_on_name"

  create_table "categories_models", :id => false, :force => true do |t|
    t.integer "categories_id"
    t.integer "models_id"
  end

  add_index "categories_models", ["categories_id", "models_id"], :name => "categories_models_index"

  create_table "kits", :force => true do |t|
    t.boolean  "tombstoned"
    t.boolean  "checkoutable"
    t.integer  "location_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "kits", ["location_id"], :name => "index_kits_on_location_id"

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "room"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "models", :force => true do |t|
    t.string   "name",                                 :null => false
    t.text     "description"
    t.boolean  "training_required", :default => false
    t.integer  "brand_id",                             :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "models", ["brand_id"], :name => "index_models_on_brand_id"

  create_table "parts", :force => true do |t|
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

  add_index "parts", ["budget_id"], :name => "index_parts_on_budget_id"
  add_index "parts", ["kit_id"], :name => "index_parts_on_kit_id"
  add_index "parts", ["model_id"], :name => "index_parts_on_model_id"

end
