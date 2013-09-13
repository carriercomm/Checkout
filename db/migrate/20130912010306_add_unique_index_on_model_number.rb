class AddUniqueIndexOnModelNumber < ActiveRecord::Migration
  def change
    add_index "component_models", ["model_number", "brand_id"], :name => "index_component_models_on_model_number_and_brand_id", :unique => true
  end
end
