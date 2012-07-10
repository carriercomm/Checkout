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

ActiveRecord::Schema.define(:version => 20120709220913) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "asset_tags", :force => true do |t|
    t.string   "uid"
    t.integer  "component_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "asset_tags", ["component_id"], :name => "index_asset_tags_on_part_id"

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

  create_table "business_hour_exceptions", :force => true do |t|
    t.integer  "location_id", :null => false
    t.date     "date_closed", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "business_hour_exceptions", ["location_id"], :name => "index_business_hour_exceptions_on_location_id"

  create_table "business_hours", :force => true do |t|
    t.integer  "location_id",  :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "open_day",     :null => false
    t.string   "open_hour",    :null => false
    t.string   "open_minute",  :null => false
    t.string   "close_day",    :null => false
    t.string   "close_hour",   :null => false
    t.string   "close_minute", :null => false
  end

  add_index "business_hours", ["location_id"], :name => "index_business_hours_on_location_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "categories", ["name"], :name => "index_categories_on_name"

  create_table "categories_models", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "model_id"
  end

  add_index "categories_models", ["category_id", "model_id"], :name => "index_categories_models_on_category_id_and_model_id"

  create_table "components", :force => true do |t|
    t.string   "serial_number"
    t.boolean  "missing",       :default => false
    t.integer  "kit_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.text     "description"
  end

  add_index "components", ["kit_id"], :name => "index_parts_on_kit_id"

  create_table "kits", :force => true do |t|
    t.boolean  "tombstoned"
    t.boolean  "checkoutable",                                :default => false
    t.integer  "location_id"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.integer  "model_id"
    t.integer  "budget_id"
    t.decimal  "cost",         :precision => 10, :scale => 0
    t.boolean  "insured",                                     :default => false
  end

  add_index "kits", ["location_id"], :name => "index_kits_on_location_id"

  create_table "locations", :force => true do |t|
    t.string   "name"
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

  create_table "reservations", :force => true do |t|
    t.integer  "kit_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "out_at"
    t.datetime "in_at"
    t.boolean  "late"
    t.integer  "client_id"
    t.text     "request_note"
    t.integer  "approver_id"
    t.text     "approval_note"
    t.integer  "out_assistant_id"
    t.integer  "in_assistant_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "reservations", ["approver_id"], :name => "index_reservations_on_approver_id"
  add_index "reservations", ["client_id"], :name => "index_reservations_on_client_id"
  add_index "reservations", ["end_at", "in_at", "late"], :name => "index_reservations_on_end_at_and_in_at_and_late"
  add_index "reservations", ["end_at"], :name => "index_reservations_on_end_at"
  add_index "reservations", ["in_assistant_id"], :name => "index_reservations_on_in_assistant_id"
  add_index "reservations", ["kit_id"], :name => "index_reservations_on_kit_id"
  add_index "reservations", ["out_assistant_id"], :name => "index_reservations_on_out_assistant_id"
  add_index "reservations", ["start_at", "out_at"], :name => "index_reservations_on_start_at_and_out_at"

  create_table "users", :force => true do |t|
    t.string   "username",                                  :null => false
    t.string   "email",                                     :null => false
    t.string   "encrypted_password",                        :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.integer  "suspension_count",       :default => 0
    t.datetime "suspended_until"
    t.boolean  "disabled",               :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
