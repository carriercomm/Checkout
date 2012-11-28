class CreateInventoryStatuses < ActiveRecord::Migration
  def change
    create_table :inventory_statuses do |t|
      t.string :name
    end
    remove_column :inventory_records, :missing
    remove_column :components, :missing
  end
end
