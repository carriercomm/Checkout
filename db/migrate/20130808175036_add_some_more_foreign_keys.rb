class AddSomeMoreForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key "component_inventory_records", "components", :name => "component_inventory_records_component_id_fk"
    add_foreign_key "component_inventory_records", "inventory_records", :name => "component_inventory_records_inventory_record_id_fk"
    add_foreign_key "component_inventory_records", "inventory_statuses", :name => "component_inventory_records_inventory_status_id_fk"
    add_foreign_key "inventory_records", "users", :name => "inventory_records_attendant_id_fk", :column => "attendant_id"
    add_foreign_key "inventory_records", "loans", :name => "inventory_records_loan_id_fk"
  end
end
