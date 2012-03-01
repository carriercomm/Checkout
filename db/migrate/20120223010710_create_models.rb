class CreateModels < ActiveRecord::Migration
  def change
    create_table :models do |t|
      t.string     :name,      :null => false
      t.text       :description
      t.boolean    :training_required, :default => false
      t.references :brand, :null => false

      t.timestamps
    end

    add_index :models, :brand_id

  end
end
