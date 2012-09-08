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

ActiveRecord::Schema.define(:version => 20120907004231) do

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

  create_table "brands", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "autocomplete", :null => false
  end

  create_table "budgets", :force => true do |t|
    t.string   "number"
    t.string   "name"
    t.date     "date_start"
    t.date     "date_end"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "business_days", :force => true do |t|
    t.integer  "index",      :null => false
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "business_days_business_hours", :force => true do |t|
    t.integer "business_day_id"
    t.integer "business_hour_id"
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
    t.integer  "open_hour",    :null => false
    t.integer  "open_minute",  :null => false
    t.integer  "close_hour",   :null => false
    t.integer  "close_minute", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "autocomplete", :null => false
  end

  add_index "categories", ["name"], :name => "index_categories_on_name"

  create_table "categories_component_models", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "component_model_id"
  end

  add_index "categories_component_models", ["category_id", "component_model_id"], :name => "index_categories_models_on_category_id_and_model_id"

  create_table "component_models", :force => true do |t|
    t.string   "name",                                 :null => false
    t.text     "description"
    t.boolean  "training_required", :default => false
    t.integer  "brand_id",                             :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "autocomplete",                         :null => false
  end

  add_index "component_models", ["brand_id"], :name => "index_models_on_brand_id"

  create_table "components", :force => true do |t|
    t.string   "serial_number"
    t.boolean  "missing",            :default => false
    t.integer  "kit_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "asset_tag"
    t.integer  "component_model_id"
    t.integer  "position"
  end

  add_index "components", ["kit_id"], :name => "index_parts_on_kit_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.date     "expires_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "groups_users", :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "kits", :force => true do |t|
    t.boolean  "tombstoned"
    t.boolean  "checkoutable", :default => false
    t.integer  "location_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "budget_id"
    t.decimal  "cost"
    t.boolean  "insured",      :default => false
  end

  add_index "kits", ["location_id"], :name => "index_kits_on_location_id"

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

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

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

  add_foreign_key "business_days_business_hours", "business_days", :name => "business_days_business_hours_business_day_id_fk"
  add_foreign_key "business_days_business_hours", "business_hours", :name => "business_days_business_hours_business_hour_id_fk"

  add_foreign_key "business_hour_exceptions", "locations", :name => "business_hour_exceptions_location_id_fk"

  add_foreign_key "business_hours", "locations", :name => "business_hours_location_id_fk"

  add_foreign_key "categories_component_models", "categories", :name => "categories_models_category_id_fk"
  add_foreign_key "categories_component_models", "component_models", :name => "categories_models_model_id_fk"

  add_foreign_key "component_models", "brands", :name => "models_brand_id_fk"

  add_foreign_key "components", "component_models", :name => "components_model_id_fk"
  add_foreign_key "components", "kits", :name => "components_kit_id_fk"

  add_foreign_key "kits", "budgets", :name => "kits_budget_id_fk"
  add_foreign_key "kits", "locations", :name => "kits_location_id_fk"

  add_foreign_key "reservations", "kits", :name => "reservations_kit_id_fk"
  add_foreign_key "reservations", "users", :name => "reservations_approver_id_fk", :column => "approver_id"
  add_foreign_key "reservations", "users", :name => "reservations_client_id_fk", :column => "client_id"
  add_foreign_key "reservations", "users", :name => "reservations_in_assistant_id_fk", :column => "in_assistant_id"
  add_foreign_key "reservations", "users", :name => "reservations_out_assistant_id_fk", :column => "out_assistant_id"

end
