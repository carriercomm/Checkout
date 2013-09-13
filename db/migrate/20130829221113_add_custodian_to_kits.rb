class AddCustodianToKits < ActiveRecord::Migration
  def change
    add_column :kits, :custodian_id, :integer
  end
end
