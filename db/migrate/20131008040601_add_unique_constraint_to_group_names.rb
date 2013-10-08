class AddUniqueConstraintToGroupNames < ActiveRecord::Migration
  def change
    add_index :groups, ["name"], :name => "index_groups_on_name", :unique => true
  end
end
