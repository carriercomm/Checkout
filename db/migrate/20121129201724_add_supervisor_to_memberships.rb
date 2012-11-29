class AddSupervisorToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :supervisor, :boolean, :default => false
  end
end
