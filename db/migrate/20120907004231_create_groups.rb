class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.date   :expires_at
      t.timestamps
    end

    create_table :groups_users do |t|
      t.references :group
      t.references :user
    end
  end
end
