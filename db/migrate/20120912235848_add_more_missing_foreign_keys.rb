class AddMoreMissingForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key "covenant_signatures", "covenants", :name => "covenant_signatures_covenant_id_fk"
    add_foreign_key "covenant_signatures", "users", :name => "covenant_signatures_user_id_fk"
    add_foreign_key "groups_users", "groups", :name => "groups_users_group_id_fk"
    add_foreign_key "groups_users", "users", :name => "groups_users_user_id_fk"
    add_foreign_key "permissions", "groups", :name => "permissions_group_id_fk"
    add_foreign_key "permissions", "kits", :name => "permissions_kit_id_fk"
    add_foreign_key "users_roles", "roles", :name => "users_roles_role_id_fk"
    add_foreign_key "users_roles", "users", :name => "users_roles_user_id_fk"
  end
end
