class CreateParts < ActiveRecord::Migration
  def change
    create_table :parts do |t|
      t.string  :serial_number
      t.decimal :cost, :precision => 8, :scale => 2
      t.boolean :insured, :default => false
      t.boolean :missing, :default => false
      t.references :budget, :null => false
      t.references :kit
      t.references :model, :null => false

      t.timestamps
    end

    add_index :parts, :budget_id
    add_index :parts, :kit_id
    add_index :parts, :model_id
    
  end
end
