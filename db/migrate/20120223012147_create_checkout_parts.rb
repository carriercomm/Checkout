class CreateCheckoutParts < ActiveRecord::Migration
  def change
    create_table :checkout_parts do |t|
      t.integer :kit_id
      t.integer :model_id, :null => false
      t.string  :serial_number
      t.decimal :cost, :precision => 8, :scale => 2
      t.boolean :insured, :default => false
      t.boolean :missing, :default => false

      t.timestamps
    end
  end
end
