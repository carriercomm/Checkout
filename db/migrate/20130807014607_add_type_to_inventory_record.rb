class AddTypeToInventoryRecord < ActiveRecord::Migration
  def change
    add_column :inventory_records, :type, :string
    remove_index "inventory_records", ["loan_id"]
    add_index  :inventory_records, [:loan_id, :component_id, :type], unique: true
  end
end
