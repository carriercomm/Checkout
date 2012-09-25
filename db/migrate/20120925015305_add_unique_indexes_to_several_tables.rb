class AddUniqueIndexesToSeveralTables < ActiveRecord::Migration
  def change
    add_index :memberships, [:user_id, :group_id], :unique => true
    add_index :permissions, [:kit_id,  :group_id], :unique => true
  end
end
