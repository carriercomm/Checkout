class AddMissingForeignKeysToTrainingAndInventoryRecord < ActiveRecord::Migration
  def change
    add_foreign_key "business_days_business_hours", "business_days", :name => "business_days_business_hours_business_day_id_fk"
    add_foreign_key "business_days_business_hours", "business_hours", :name => "business_days_business_hours_business_hour_id_fk"
    add_foreign_key "inventory_records", "users", :name => "inventory_records_attendant_id_fk", :column => "attendant_id"
    add_foreign_key "inventory_records", "components", :name => "inventory_records_component_id_fk"
    add_foreign_key "inventory_records", "loans", :name => "inventory_records_loan_id_fk"
    add_foreign_key "trainings", "component_models", :name => "trainings_component_model_id_fk"
    add_foreign_key "trainings", "users", :name => "trainings_user_id_fk"
  end
end
