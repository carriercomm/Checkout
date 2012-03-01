class CreateCheckoutKits < ActiveRecord::Migration
  def change
    create_table :checkout_kits do |t|
      t.boolean :tombstoned
      t.boolean :checkoutable
      t.references :location

      t.timestamps
    end
    add_index :checkout_kits, :location_id
  end
end
