class AddUniquenessConstraintsToRolesAndLostAtToLoan < ActiveRecord::Migration
  def change
    remove_index "roles", ["name", "resource_type", "resource_id"]
    add_index "roles", ["name", "resource_type", "resource_id"], :unique => true

    remove_index "users_roles", ["user_id", "role_id"]
    add_index "users_roles", ["user_id", "role_id"], :unique => true

    remove_index "settings", ["var"]
    add_index "settings", ["var"], :unique => true

    add_column "loans", "lost_at", :datetime

  end
end
