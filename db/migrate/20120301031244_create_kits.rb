class CreateKits < ActiveRecord::Migration
  def change
    create_table :kits do |t|
      t.boolean :tombstoned
      t.boolean :checkoutable
      t.references :location

      t.timestamps
    end
    add_index :kits, :location_id
  end
end
