class AddKitIdToInventoryAndRenameComponentInventoryRecords < ActiveRecord::Migration
  def change
    rename_table :component_inventory_records, :inventory_details
    add_column "inventory_records", "kit_id", :integer, :null => false
    add_foreign_key "inventory_records", "kits", :name => "inventory_records_kit_id_fk"
  end
end
