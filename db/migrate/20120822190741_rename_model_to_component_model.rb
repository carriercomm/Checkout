class RenameModelToComponentModel < ActiveRecord::Migration
  def change
    rename_table :models, :component_models
    rename_table :categories_models, :categories_component_models
    rename_column :components, :model_id, :component_model_id
    rename_column :categories_component_models, :model_id, :component_model_id
  end
end
