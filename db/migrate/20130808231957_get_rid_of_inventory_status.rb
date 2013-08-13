class GetRidOfInventoryStatus < ActiveRecord::Migration
  def change
    remove_column :inventory_details, :inventory_status_id
    add_column :inventory_details, :missing, :boolean, :default => false, :null => false
    add_column :components, :accessioned_at, :datetime
    add_column :components, :deaccessioned_at, :datetime
    drop_table :inventory_statuses
    remove_index "inventory_records", ["attendant_id"]
    add_index "inventory_records", ["attendant_id"] # change to non-unique
  end
end
