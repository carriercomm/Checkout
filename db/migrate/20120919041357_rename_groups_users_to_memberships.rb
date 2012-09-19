class RenameGroupsUsersToMemberships < ActiveRecord::Migration
  def up
    rename_table :groups_users, :memberships
  end

  def down
    rename_table :memberships, :groups_users
  end
end
