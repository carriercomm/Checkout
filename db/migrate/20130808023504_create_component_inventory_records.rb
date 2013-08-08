class CreateComponentInventoryRecords < ActiveRecord::Migration
  def change
    drop_table :inventory_records
    drop_table :component_inventory_records

    remove_column :loans, :in_attendant_id
    remove_column :loans, :out_attendant_id

    create_table "inventory_records", :force => true do |t|
      t.integer  "loan_id"
      t.integer  "attendant_id", :null => false
      t.string   "type", :null => false
      t.timestamps
    end
    add_index :inventory_records, [:loan_id, :type], unique: true
    add_index :inventory_records, :attendant_id, unique: true

    create_table :component_inventory_records do |t|
      t.references :component, null: false
      t.references :inventory_status, null: false
      t.references :inventory_record, null: false
      t.timestamps
    end
    add_index :component_inventory_records, [:component_id, :inventory_record_id], name: 'index_comp_inv_rec_on_component_id_and_inventory_record_id', unique: true
    add_index :component_inventory_records, :inventory_status_id
    add_index :component_inventory_records, :inventory_record_id

  end
end
