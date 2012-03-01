class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.text :description

      t.timestamps
    end

    add_index :categories, [:name]

    create_table :categories_models, :id => false do |t|
      t.references :categories, :models
    end

    add_index :categories_models, [:categories_id, :models_id], :name => 'categories_models_index'

  end
end
