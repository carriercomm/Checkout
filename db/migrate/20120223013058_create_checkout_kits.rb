class CreateCheckoutKits < ActiveRecord::Migration
  def change
    create_table :checkout_kits do |t|
      t.integer :location_id,  :null    => false
      t.boolean :tombstoned,   :default => false
      t.boolean :checkoutable, :default => false

      t.timestamps
    end
  end
end
