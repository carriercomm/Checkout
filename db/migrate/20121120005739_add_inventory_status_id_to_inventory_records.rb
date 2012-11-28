class AddInventoryStatusIdToInventoryRecords < ActiveRecord::Migration
  def change
    add_column :inventory_records, :inventory_status_id, :integer, :null => false
  end
end
