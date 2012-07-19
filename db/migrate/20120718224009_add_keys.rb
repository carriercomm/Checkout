class AddKeys < ActiveRecord::Migration
  def change
    add_foreign_key "business_days_business_hours", "business_days", :name => "business_days_business_hours_business_day_id_fk"
    add_foreign_key "business_days_business_hours", "business_hours", :name => "business_days_business_hours_business_hour_id_fk"
    add_foreign_key "business_hour_exceptions", "locations", :name => "business_hour_exceptions_location_id_fk"
    add_foreign_key "business_hours", "locations", :name => "business_hours_location_id_fk"
    add_foreign_key "categories_models", "categories", :name => "categories_models_category_id_fk"
    add_foreign_key "categories_models", "models", :name => "categories_models_model_id_fk"
    add_foreign_key "components", "kits", :name => "components_kit_id_fk"
    add_foreign_key "components", "models", :name => "components_model_id_fk"
    add_foreign_key "kits", "budgets", :name => "kits_budget_id_fk"
    add_foreign_key "kits", "locations", :name => "kits_location_id_fk"
    add_foreign_key "models", "brands", :name => "models_brand_id_fk"
    add_foreign_key "reservations", "users", :name => "reservations_approver_id_fk", :column => "approver_id"
    add_foreign_key "reservations", "users", :name => "reservations_client_id_fk", :column => "client_id"
    add_foreign_key "reservations", "users", :name => "reservations_in_assistant_id_fk", :column => "in_assistant_id"
    add_foreign_key "reservations", "kits", :name => "reservations_kit_id_fk"
    add_foreign_key "reservations", "users", :name => "reservations_out_assistant_id_fk", :column => "out_assistant_id"
  end
end
