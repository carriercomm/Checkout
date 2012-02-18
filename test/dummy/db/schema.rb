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

ActiveRecord::Schema.define(:version => 20120218030130) do

  create_table "attention_eq", :primary_key => "atten_id", :force => true do |t|
    t.integer "eq_uw_tag",                           :default => 0,    :null => false
    t.text    "notes",         :limit => 2147483647,                   :null => false
    t.string  "attended",      :limit => 3,          :default => "No", :null => false
    t.date    "date_attended",                                         :null => false
    t.string  "staff_id",      :limit => 20,         :default => "",   :null => false
  end

  create_table "budgets", :primary_key => "budget_id", :force => true do |t|
    t.string "budget_number", :limit => 12, :default => "", :null => false
    t.string "budget_name",   :limit => 30, :default => "", :null => false
  end

  create_table "bundle_items", :primary_key => "bundle_id", :force => true do |t|
    t.integer "eq_uw_tag",                        :default => 0,  :null => false
    t.text    "bundle_notes", :limit => 16777215,                 :null => false
    t.string  "color",        :limit => 8,        :default => "", :null => false
  end

  create_table "bundles", :primary_key => "bundle_id", :force => true do |t|
    t.integer "eq_uw_tag"
    t.text    "bundle_notes", :limit => 16777215
    t.string  "color",        :limit => 8
    t.string  "status",       :limit => 15,       :default => "OK", :null => false
  end

  create_table "checkout", :primary_key => "checkout_id", :force => true do |t|
    t.integer "res_id"
    t.string  "client_id",   :limit => 20, :default => "", :null => false
    t.integer "eq_uw_tag",                 :default => 0,  :null => false
    t.date    "dateout",                                   :null => false
    t.string  "staffout_id", :limit => 15, :default => "", :null => false
    t.date    "datedue",                                   :null => false
    t.date    "datein"
    t.string  "staffin_id",  :limit => 15
  end

  create_table "checkout_budgets", :force => true do |t|
    t.string   "number"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "clients", :primary_key => "client_id", :force => true do |t|
    t.string "name",                   :limit => 40, :default => "",   :null => false
    t.string "email",                  :limit => 50, :default => "",   :null => false
    t.string "stat_of_responsibility", :limit => 3,  :default => "No", :null => false
  end

  create_table "clients_status", :primary_key => "status_id", :force => true do |t|
    t.string  "client_id", :limit => 20, :default => "", :null => false
    t.integer "group_id",                :default => 1,  :null => false
  end

  create_table "eq_categories", :primary_key => "cat_id", :force => true do |t|
    t.string "category",  :limit => 30,       :default => "", :null => false
    t.text   "cat_notes", :limit => 16777215
  end

  create_table "equipment", :primary_key => "eq_uw_tag", :force => true do |t|
    t.integer "eq_req_num"
    t.integer "eq_procard"
    t.integer "budget_id"
    t.string  "eq_budget_biennium", :limit => 10
    t.string  "eq_model",           :limit => 40,       :default => "",   :null => false
    t.string  "eq_manufacturer",    :limit => 40
    t.text    "eq_description",     :limit => 16777215
    t.integer "loc_id",                                 :default => 1,    :null => false
    t.integer "cat_id",                                 :default => 5,    :null => false
    t.string  "special",            :limit => 3,        :default => "No", :null => false
    t.integer "eq_cost"
    t.string  "eq_serial_num",      :limit => 40
    t.date    "eq_date_entered"
    t.string  "eq_insured",         :limit => 3
    t.string  "eq_removed",         :limit => 3
    t.string  "checkoutable",       :limit => 3,        :default => "No", :null => false
  end

  create_table "equipment_notes", :primary_key => "eqnotes_id", :force => true do |t|
    t.integer "eq_uw_tag",                        :default => 0, :null => false
    t.text    "eqnotes",      :limit => 16777215,                :null => false
    t.date    "eqnotes_date",                                    :null => false
  end

  create_table "groups", :primary_key => "group_id", :force => true do |t|
    t.string "group_name",        :limit => 30,       :default => "", :null => false
    t.text   "group_description", :limit => 16777215
  end

  create_table "inventory", :primary_key => "inventory_id", :force => true do |t|
    t.integer "eq_uw_tag",                            :default => 0, :null => false
    t.string  "building",         :limit => 20
    t.string  "room",             :limit => 10
    t.date    "date_inventoried"
    t.string  "staff_id",         :limit => 20
    t.text    "inventory_notes",  :limit => 16777215
  end

  create_table "late", :primary_key => "late_id", :force => true do |t|
    t.integer "checkout_id",                                      :null => false
    t.text    "notes",       :limit => 2147483647,                :null => false
    t.integer "level",                             :default => 0, :null => false
  end

  create_table "locations", :primary_key => "loc_id", :force => true do |t|
    t.string "loc_name", :limit => 30, :null => false
  end

  create_table "media_library", :primary_key => "name", :force => true do |t|
    t.integer "number", :null => false
  end

  add_index "media_library", ["number"], :name => "number"

  create_table "notifications", :primary_key => "notif_id", :force => true do |t|
    t.string "client_id",      :limit => 20,       :default => "", :null => false
    t.text   "notification",   :limit => 16777215
    t.date   "when_to_notify",                                     :null => false
  end

  create_table "reservation", :primary_key => "res_id", :force => true do |t|
    t.date    "resdate",                                   :null => false
    t.date    "resdate_end"
    t.integer "eq_uw_tag",                 :default => 0,  :null => false
    t.string  "client_id",   :limit => 20, :default => "", :null => false
  end

  create_table "restricted_eq", :primary_key => "restrict_id", :force => true do |t|
    t.integer "group_id",  :default => 0, :null => false
    t.integer "eq_uw_tag", :default => 0, :null => false
  end

  create_table "special_dates", :primary_key => "specdat_id", :force => true do |t|
    t.date "specdat",                :null => false
    t.text "notes",   :limit => 255
  end

  create_table "special_items", :primary_key => "special_id", :force => true do |t|
    t.integer "eq_uw_tag",               :default => 0,  :null => false
    t.string  "client_id", :limit => 20, :default => "", :null => false
  end

end
