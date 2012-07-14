class RefactorModelKitComponentRelationship < ActiveRecord::Migration
  def up
    drop_table :asset_tags
    add_column :components, :asset_tag, :string
    add_column :components, :model_id, :integer
    remove_column :components, :description
    remove_column :kits, :model_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
