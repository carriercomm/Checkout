class CreateCheckoutAssetTags < ActiveRecord::Migration
  def change
    create_table :checkout_asset_tags do |t|
      t.string :uid
      t.references :part

      t.timestamps
    end
    add_index :checkout_asset_tags, :part_id
  end
end
