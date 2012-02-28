class CreateCheckoutModels < ActiveRecord::Migration
  def change
    create_table :checkout_models do |t|
      t.integer :maker_id,  :null => false
      t.string  :name,      :null => false
      t.text    :description
      t.boolean :training_required, :default => false

      t.timestamps
    end
  end
end
