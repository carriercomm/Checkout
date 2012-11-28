class CreateInventoryRecords < ActiveRecord::Migration
  def change
    create_table :inventory_records do |t|
      t.boolean :missing, :default => false
      t.references :component, :null => false
      t.references :loan
      t.references :attendant, :null => false

      t.timestamps
    end
    add_index :inventory_records, :component_id
    add_index :inventory_records, :loan_id
    add_index :inventory_records, :attendant_id
  end
end
