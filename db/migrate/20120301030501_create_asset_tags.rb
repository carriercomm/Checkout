class CreateAssetTags < ActiveRecord::Migration
  def change
    create_table :asset_tags do |t|
      t.string :uid
      t.references :part

      t.timestamps
    end
    add_index :asset_tags, :part_id
  end
end
