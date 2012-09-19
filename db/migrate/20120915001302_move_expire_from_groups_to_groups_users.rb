class MoveExpireFromGroupsToGroupsUsers < ActiveRecord::Migration
  def up
    remove_column :groups, :expires_at
    add_column  :groups_users, :expires_at, :date
  end

  def down
    add_column :groups, :expires_at, :date
    remove_column  :groups_users, :expires_at
  end
end
