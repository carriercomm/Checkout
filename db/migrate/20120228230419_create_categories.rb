class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.text :description

      t.timestamps
    end

    add_index :categories, [:name]

    create_table :categories_models, :id => false do |t|
      t.references :category, :model
    end

    add_index :categories_models, [:category_id, :model_id]

  end
end
