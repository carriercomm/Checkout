class CreateCheckoutCategories < ActiveRecord::Migration
  def change
    create_table :checkout_categories do |t|
      t.string :name
      t.text :description

      t.timestamps
    end

    add_index :checkout_categories, [:name]

    create_table :checkout_categories_checkout_models, :id => false do |t|
      t.references :checkout_categories, :checkout_models
    end

    add_index :checkout_categories_checkout_models, [:checkout_categories_id, :checkout_models_id], :name => 'categories_models_index'

  end
end
